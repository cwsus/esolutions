#!/usr/bin/env ksh
#==============================================================================
#
#          FILE:  run_decom.sh
#         USAGE:  ./run_decom.sh
#   DESCRIPTION:  Executes the necessary classes against the configured DNS
#                 master to fail over a single site.
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Kevin Huntly <kmhuntly@gmail.com>
#       COMPANY:  CaspersBox Web Services
#       VERSION:  1.0
#       CREATED:  ---
#      REVISION:  ---
#==============================================================================

[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -x;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -x;

## Application constants
CNAME="$(basename "${0}")";
SCRIPT_ABSOLUTE_PATH="$(cd "${0%/*}" 2>/dev/null; printf "${PWD}"/"${0##*/}")";
SCRIPT_ROOT="$(dirname "${SCRIPT_ABSOLUTE_PATH}")";
METHOD_NAME="${THIS_CNAME}#startup";

[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +x;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +x;

[[ -z "${PLUGIN_ROOT_DIR}" && -f ${SCRIPT_ROOT}/../lib/plugin.sh ]] && . ${SCRIPT_ROOT}/../lib/plugin.sh;

[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -x;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -x;

[ -z "${PLUGIN_ROOT_DIR}" ] && print "Failed to locate configuration data. Cannot continue." && exit 1;

[ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${CNAME} starting up.. Process ID ${$}";
[ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";
[ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Provided arguments: ${@}";

THIS_CNAME="${CNAME}";
unset METHOD_NAME;
unset CNAME;

[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +x;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +x;

## validate the input
${APP_ROOT}/${LIB_DIRECTORY}/validateSecurityAccess.sh -a;
typeset -i RET_CODE=${?};

[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -x;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -x;

CNAME="${THIS_CNAME}";
METHOD_NAME="${THIS_CNAME}#startup";

[ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";

if [ -z "${RET_CODE}" ] || [ ${RET_CODE} -ne 0 ]
then
    ${LOGGER} "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Security violation found while executing ${CNAME} by ${IUSER_AUDIT} on host ${SYSTEM_HOSTNAME}";
    ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Security configuration blocks execution. Please verify security configuration.";

    print "Security configuration does not allow the requested action.";

    return ${RET_CODE};
fi

unset RET_CODE;

#===  FUNCTION  ===============================================================
#          NAME:  failover_site
#   DESCRIPTION:  Processes and implements a DNS site failover
#    PARAMETERS:  Parameters obtained via command-line flags
#          NAME:  usage for positive result, >1 for non-positive
#==============================================================================
function decom_site
{
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -x;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -x;
    local METHOD_NAME="${CNAME}#${0}";
    local RETURN_CODE=0;

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Provided arguments: ${@}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "UNIT -> ${UNIT}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PRJCODE -> ${PRJCODE}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "ZONE_NAME -> ${ZONE_NAME}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CHG_CTRL -> ${CHG_CTRL}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "IUSER_AUDIT -> ${IUSER_AUDIT}";

    ## our request type is p <project code> or u <url>
    ## both can be run against the same script, as its
    ## a single-zone change
    ## spawn an ssh connection to the DNS master
    if [[ ! -z "${LOCAL_EXECUTION}" && "${LOCAL_EXECUTION}" = "${_TRUE}" ]]
    then
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Local execution is true. Processing..";

        if [ ! -z "${SLAVE_COPY}" ] && [ "${SLAVE_COPY}" = "${_TRUE}" ]
        then
            ## execute on a slave, provide the necessary options
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Slave server targetted. Processing..";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command execute_decom.sh -b ${UNIT} -p ${PRJCODE} -z "${ZONE_NAME}" -i ${IUSER_AUDIT} -c ${CHG_CTRL} -s -e ..";

            unset CNAME;
            unset METHOD_NAME;

            . ${PLUGIN_LIB_DIRECTORY}/executors/execute_decom.sh -b ${UNIT} -p ${PRJCODE} -z "${ZONE_NAME}" -i ${IUSER_AUDIT} -c ${CHG_CTRL} -s -e;

            CNAME="${THIS_CNAME}";
            local METHOD_NAME="${CNAME}#${0}";
        else
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command execute_decom.sh -b ${UNIT} -p ${PRJCODE} -z "${ZONE_NAME}" -i ${IUSER_AUDIT} -c ${CHG_CTRL} -s -e ..";

            ## temp unset
            unset CNAME;
            unset METHOD_NAME;

            . ${PLUGIN_LIB_DIRECTORY}/executors/execute_decom.sh -b ${UNIT} -p ${PRJCODE} -z "${ZONE_NAME}" -i ${IUSER_AUDIT} -c ${CHG_CTRL} -e;

            CNAME="${THIS_CNAME}";
            local METHOD_NAME="${CNAME}#${0}";
        fi
    else
        ## remote exec
        if [ ! -z "${SLAVE_COPY}" ] && [ "${SLAVE_COPY}" = "${_TRUE}" ]
        then
            ## execute on a slave, provide the necessary options
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Slave server targetted. Executing against ${SLAVE_SERVER}..";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command runSSHConnection.exp ${SLAVE_SERVER} ${REMOTE_APP_ROOT}/${PLUGIN_LIB_DIRECTORY}/executors/execute_decom.sh -b ${UNIT} -p ${PRJCODE} -z "${ZONE_NAME}" -i ${IUSER_AUDIT} -c ${CHG_CTRL} -s -e ..";

            ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSSHConnection.exp ${SLAVE_SERVER} "${REMOTE_APP_ROOT}/${PLUGIN_LIB_DIRECTORY}/executors/execute_decom.sh -b ${UNIT} -p ${PRJCODE} -z "${ZONE_NAME}" -i ${IUSER_AUDIT} -c ${CHG_CTRL} -s -e" ${SSH_USER_NAME} ${SSH_USER_AUTH};
        else
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command runSSHConnection.exp ${SLAVE_SERVER} ${REMOTE_APP_ROOT}/${PLUGIN_LIB_DIRECTORY}/executors/execute_decom.sh -b ${UNIT} -p ${PRJCODE} -z "${ZONE_NAME}" -i ${IUSER_AUDIT} -c ${CHG_CTRL} -e ..";

            ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSSHConnection.exp ${NAMED_MASTER} "${REMOTE_APP_ROOT}/${PLUGIN_LIB_DIRECTORY}/executors/execute_decom.sh -b ${UNIT} -p ${PRJCODE} -z "${ZONE_NAME}" -i ${IUSER_AUDIT} -c ${CHG_CTRL} -e" ${SSH_USER_NAME} ${SSH_USER_AUTH};
        fi
    fi

    ## capture the return code from the operations
    typeset -i RET_CODE=${?};

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Command execution complete. RET_CODE -> ${RET_CODE}";

    if [ ${RET_CODE} -eq 0 ]
    then
        ## failover was successful. lets do some more work...
        unset RET_CODE;

        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failover completed. Reloading server configuration..";
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command runRNDCCommands.sh -s ${NAMED_MASTER} -c reload -e..";

        unset CNAME;
        unset METHOD_NAME;

        ## send an rndc reload to the server to make it active
        . ${PLUGIN_LIB_DIRECTORY}/runRNDCCommands.sh -s ${NAMED_MASTER} -c reload -e;
        RNDC_CODE=${?};

        CNAME="${THIS_CNAME}";
        local METHOD_NAME="${CNAME}#${0}";

        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RNDC_CODE -> ${RNDC_CODE}";

        if [ ${RNDC_CODE} -eq 0 ]
        then
            ## we've successfully reloaded our configuration. verify that the change was indeed made
            unset RNDC_CODE;

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Decommission complete. Sending notifies..";

            unset RET_CODE;
            unset RETURN_TEXT;

            ## temp unset
            unset CNAME;
            unset METHOD_NAME;

            ## send out a notification email advising of the failover.
            . ${MAILER_CLASS} -m notifyDecommission -p ${PROJECT_CODE} -a "${DNS_SERVER_ADMIN_EMAIL}" -e;

            CNAME="${THIS_CNAME}";
            local METHOD_NAME="${CNAME}#${0}";

            ${LOGGER} "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${LOGGER} "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "DNS decommission: Requestor: ${IUSER_AUDIT} - Date: $(date +"%d-%m-%Y") - Site: ${UNIT}/${PRJCODE}/${FILENAME} - Change Request: ${CHG_CTRL} - Switched To: ${TARGET}")";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

            RETURN_CODE=0;
        else
            ## our server reload failed. throw an "ERROR", we can't recover from this here.
            ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Server reload on ${NAMED_MASTER} has failed. Unable to proceed.";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

            RETURN_CODE=52;
        fi
    else
        ## failover process has failed. inform.
        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failover processing on ${NAMED_MASTER} has failed. Unable to proceed.";
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

        RETURN_CODE=${RET_CODE};
    fi

    unset UNIT;
    unset FILENAME;
    unset TARGET;
    unset PRJCODE;
    unset CHG_CTRL;
    unset FAILOVER_CODE;

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +x;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +x;

    return ${RETURN_CODE};
}

#===  FUNCTION  ===============================================================
#          NAME:  failover_bu
#   DESCRIPTION:  Processes and implements a DNS site failover
#    PARAMETERS:  Parameters obtained via command-line flags
#          NAME:  usage for positive result, >1 for non-positive
#==============================================================================
function decom_bu
{
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -x;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -x;
    local METHOD_NAME="${CNAME}#${0}";
    local RETURN_CODE=0;

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Provided arguments: ${@}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "UNIT->${UNIT}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CHG_CTRL->${CHG_CTRL}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "IUSER_AUDIT -> ${IUSER_AUDIT}";

    ## our request type is p <project code> or u <url>
    ## both can be run against the same script, as its
    ## a single-zone change
    ## spawn an ssh connection to the DNS master
    if [[ ! -z "${LOCAL_EXECUTION}" && "${LOCAL_EXECUTION}" = "${_TRUE}" ]]
    then
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Local execution is true. Processing..";

        if [ ! -z "${SLAVE_COPY}" ] && [ "${SLAVE_COPY}" = "${_TRUE}" ]
        then
            ## execute on a slave, provide the necessary options
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Slave server targetted. Executing..";

            unset CNAME;
            unset METHOD_NAME;

            . ${PLUGIN_LIB_DIRECTORY}/executors/execute_decom.sh -b ${UNIT} -i ${IUSER_AUDIT} -c ${CHANGE_NUM} -s -e;

            CNAME="${THIS_CNAME}";
            local METHOD_NAME="${CNAME}#${0}";
        else
            unset CNAME;
            unset METHOD_NAME;

            . ${PLUGIN_LIB_DIRECTORY}/executors/execute_decom.sh -b ${UNIT} -i ${IUSER_AUDIT} -c ${CHANGE_NUM} -s -e;

            CNAME="${THIS_CNAME}";
            local METHOD_NAME="${CNAME}#${0}";
        fi
    else
        ## remote exec
        if [ ! -z "${SLAVE_COPY}" ] && [ "${SLAVE_COPY}" = "${_TRUE}" ]
        then
            ## execute on a slave, provide the necessary options
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Slave server targetted. Executing against ${SLAVE_SERVER}..";

            ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSSHConnection.exp ${SLAVE_SERVER} "${REMOTE_APP_ROOT}/${PLUGIN_LIB_DIRECTORY}/executors/execute_decom.sh -b ${UNIT} -i ${IUSER_AUDIT} -c ${CHANGE_NUM} -s -e" ${SSH_USER_NAME} ${SSH_USER_AUTH};
        else
            ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSSHConnection.exp ${NAMED_MASTER} "${REMOTE_APP_ROOT}/${PLUGIN_LIB_DIRECTORY}/executors/execute_decom.sh -b ${UNIT} -i ${IUSER_AUDIT} -c ${CHANGE_NUM} -e" ${SSH_USER_NAME} ${SSH_USER_AUTH};
        fi
    fi

    ## capture the return code from the operations
    typeset -i RET_CODE=${?};

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";

    if [ ${FAILOVER_CODE} -eq 0 ]
    then
        ## failover was successful. lets do some more work...
        unset RET_CODE;

        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failover completed. Reloading server configuration..";
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command runRNDCCommands.sh -s ${NAMED_MASTER} -c reload -e..";

        unset CNAME;
        unset METHOD_NAME;

        ## send an rndc reload to the server to make it active
        . ${PLUGIN_LIB_DIRECTORY}/runRNDCCommands.sh -s ${NAMED_MASTER} -c reload -e;
        RNDC_CODE=${?};

        CNAME="${THIS_CNAME}";
        local METHOD_NAME="${CNAME}#${0}";

        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RNDC_CODE -> ${RNDC_CODE}";

        if [ ${RNDC_CODE} -eq 0 ]
        then
            ## we've successfully reloaded our configuration. verify that the change was indeed made
            unset RNDC_CODE;

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Decommission complete. Sending notifies..";

            unset RET_CODE;
            unset RETURN_TEXT;

            ## temp unset
            unset CNAME;
            unset METHOD_NAME;

            ## send out a notification email advising of the decom.
            ## only send if we made a change on the master
            if [ -z "${SLAVE_COPY}" ] || [ "${SLAVE_COPY}" != "${_TRUE}" ]
            then
                . ${MAILER_CLASS} -m notifyDecommission -p ${PROJECT_CODE} -a "${DNS_SERVER_ADMIN_EMAIL}" -e;
            fi

            CNAME="${THIS_CNAME}";
            local METHOD_NAME="${CNAME}#${0}";

            ${LOGGER} "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${LOGGER} "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "DNS decommission: Requestor: ${IUSER_AUDIT} - Date: $(date +"%d-%m-%Y") - Site: ${UNIT}/${PRJCODE}/${FILENAME} - Change Request: ${CHG_CTRL} - Switched To: ${TARGET}")";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

            RETURN_CODE=0;
        else
            ## our server reload failed. throw an "ERROR", we can't recover from this here.
            ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Server reload on ${NAMED_MASTER} has failed. Unable to proceed.";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

            RETURN_CODE=52;
        fi
    else
        ## failover process has failed. inform.
        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failover processing on ${NAMED_MASTER} has failed. Unable to proceed.";

        RETURN_CODE=${FAILOVER_CODE};
    fi

    unset UNIT;
    unset FILENAME;
    unset TARGET;
    unset PRJCODE;
    unset CHG_CTRL;
    unset FAILOVER_CODE;

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +x;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +x;

    return ${RETURN_CODE};
}

#===  FUNCTION  ===============================================================
#          NAME:  usage
#   DESCRIPTION:  Provide information on the function usage of this application
#    PARAMETERS:  None
#          NAME:  usage
#==============================================================================
function usage
{
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -x;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -x;
    local METHOD_NAME="${CNAME}#${0}";
    local RETURN_CODE=3;

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Provided arguments: ${@}";

    print "${CNAME} - Execute a DNS failover request on the master nameserver based on the provided information.";
    print "Usage: ${CNAME} [ -s <request data> ] [ -b requestdata ] [ -d server ] [ -e execute ] [-?|-h show this help]";
    print "  -s      Process a site failover based on a comma-delimited information set";
    print "  -b      Process a business unit failover based on a comma-delimited information set";
    print "  -d      If provided, operates against a provided slave server";
    print "  -e      Execute processing";
    print "  -h|-?   Show this help";

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RETURN_CODE -> ${RETURN_CODE}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +x;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +x;

    return ${RETURN_CODE};
}

[ ${#} -eq 0 ] && usage && RETURN_CODE=${?};

while getopts ":s:b:d:eh:" OPTIONS 2>/dev/null
do
    case "${OPTIONS}" in
        s)
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting dataset..";

            DECOM_TYPE="site";

            ## comma-delimited information set, lets strip the "INFO"
            UNIT=$(printf "${OPTARG}" | cut -d "," -f 1);
            PRJCODE=$(printf "${OPTARG}" | cut -d "," -f 2);
            ZONE_NAME=$(printf "${OPTARG}" | cut -d "," -f 3);
            CHG_CTRL=$(printf "${OPTARG}" | cut -d "," -f 4);
            IUSER_AUDIT=$(printf "${OPTARG}" | cut -d "," -f 5);

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "DECOM_TYPE -> ${DECOM_TYPE}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "UNIT -> ${UNIT}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PRJCODE -> ${PRJCODE}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "ZONE_NAME -> ${ZONE_NAME}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CHG_CTRL -> ${CHG_CTRL}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "IUSER_AUDIT -> ${IUSER_AUDIT}";
            ;;
        b)
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting dataset..";

            DECOM_TYPE="unit";

            ## comma-delimited information set, lets strip the "INFO"
            UNIT=$(printf "${OPTARG}" | cut -d "," -f 2);
            CHG_CTRL=$(printf "${OPTARG}" | cut -d "," -f 4);
            IUSER_AUDIT=$(printf "${OPTARG}" | cut -d "," -f 5);

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "DECOM_TYPE->${DECOM_TYPE}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "UNIT->${UNIT}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CHG_CTRL->${CHG_CTRL}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "IUSER_AUDIT->${IUSER_AUDIT}";
            ;;
        d)
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting SLAVE_COPY to true..";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting SLAVE_SYSTEM..";

            SLAVE_COPY=${_TRUE};
            typeset -l SLAVE_SERVER="${OPTARG}";

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "SLAVE_COPY -> ${SLAVE_COPY}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "SLAVE_SERVER -> ${SLAVE_SERVER}";
            ;;
        e)
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Validating request..";

            if [ -z "${UNIT}" ]
            then
                ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No business unit was provided. Unable to continue processing.";
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                unset FAILOVER_TYPE;
                unset UNIT;
                unset FILENAME;
                unset TARGET;
                unset PRJCODE;
                unset CHG_CTRL;

                RETURN_CODE=15;
            elif [ -z "${CHG_CTRL}" ]
            then
                ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No change number was provided. Unable to continue processing.";
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                unset FAILOVER_TYPE;
                unset UNIT;
                unset FILENAME;
                unset TARGET;
                unset PRJCODE;
                unset CHG_CTRL;

                RETURN_CODE=19;
            elif [ -z "${IUSER_AUDIT}" ]
            then
                ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Unable to "AUDIT" user account. Unable to continue processing.";
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                unset FAILOVER_TYPE;
                unset UNIT;
                unset FILENAME;
                unset TARGET;
                unset PRJCODE;
                unset CHG_CTRL;

                RETURN_CODE=20;
            else
                ## We have enough information to process the request, continue
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Request validated - executing.";
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                if [ ! -z "${DECOM_TYPE}" ]
                then
                    if [ "${DECOM_TYPE}" = "unit" ]
                    then
                        decom_bu && RETURN_CODE=${?};
                    elif [ "${DECOM_TYPE}" = "site" ]
                    then
                        if [ -z "${ZONE_NAME}" ] || [ -z "${PRJCODE}" ]
                        then
                            ## require a zone name for a site decom
                            ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "A valid zone name or project code was not provided. Cannot continue.";

                            RETURN_CODE=3;
                        else
                            decom_site && RETURN_CODE=${?};
                        fi
                    else
                        ## no valid decommission type was provided
                        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "A valid decommission request type was not provided. Cannot continue.";

                        RETURN_CODE=3;
                    fi
                else
                    ## no decommission type was provided
                    ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No decommission request type was provided. Cannot continue.";

                    RETURN_CODE=3;
                fi
            fi
            ;;
    esac
done

[ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RETURN_CODE -> ${RETURN_CODE}";
[ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${CNAME} -> exit";

unset SCRIPT_ABSOLUTE_PATH;
unset SCRIPT_ROOT;
unset THIS_CNAME;
unset RET_CODE;
unset CNAME;
unset METHOD_NAME;

[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +x;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +x;

return ${RETURN_CODE};

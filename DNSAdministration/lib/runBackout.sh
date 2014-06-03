#!/usr/bin/env ksh
#==============================================================================
#
#          FILE:  runBackout.sh
#         USAGE:  ./runBackout.sh
#   DESCRIPTION:  Processes backout requests for previously executed change
#                 requests.
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
## Application constants
[ -z "${PLUGIN_NAME}" ] && PLUGIN_NAME="DNSAdministration";
CNAME="$(basename "${0}")";
SCRIPT_ABSOLUTE_PATH="$(cd "${0%/*}" 2>/dev/null; echo "${PWD}"/"${0##*/}")";
SCRIPT_ROOT="$(dirname "${SCRIPT_ABSOLUTE_PATH}")";

[[ -z "${PLUGIN_ROOT_DIR}" && -s ${SCRIPT_ROOT}/../${LIB_DIRECTORY}/${PLUGIN_NAME}.sh ]] && . ${SCRIPT_ROOT}/../${LIB_DIRECTORY}/${PLUGIN_NAME}.sh;
[ -z "${PLUGIN_ROOT_DIR}" ] && exit 1

[[ ! -z "${TRACE}" && "${TRACE}" = "${_TRUE}" ]] && set -x;

OPTIND=0;
METHOD_NAME="${CNAME}#startup";

[ ${#} -eq 0 ] && usage;

[[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${CNAME} starting up.. Process ID ${$}";
[[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Provided arguments: ${@}";
[[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";

unset METHOD_NAME;
unset CNAME;

## check security
. ${PLUGIN_ROOT_DIR}/${LIB_DIRECTORY}/security/check_main.sh > /dev/null 2>&1;
RET_CODE=${?};

[ ${RET_CODE} != 0 ] && echo "Security configuration does not allow the requested action." && exit ${RET_CODE};

## unset the return code
unset RET_CODE;

CNAME="$(basename "${0}")";
METHOD_NAME="${CNAME}#startup";

#===  FUNCTION  ===============================================================
#          NAME:  obtainBackoutList
#   DESCRIPTION:  Processes and implements a DNS site failover
#    PARAMETERS:  Parameters obtained via command-line flags
#          NAME:  usage for positive result, >1 for non-positive
#==============================================================================
function obtainBackoutList
{
    [[ ! -z "${TRACE}" && "${TRACE}" = "${_TRUE}" ]] && set -x;
    local METHOD_NAME="${CNAME}#${0}";

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";
    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Retrieving list of available backout files..";

    ## spawn an ssh connection to the DNS master to obtain a list of all
    ## available backout tarballs
    if [[ ! -z "${LOCAL_EXECUTION}" && "${LOCAL_EXECUTION}" = "${_TRUE}" ]]
    then
        . ${PLUGIN_ROOT_DIR}/${LIB_DIRECTORY}/executors/execute_backout.sh -a;
        RETURN_CODE=${?};
    else
        ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSSHConnection.exp ${NAMED_MASTER} "${REMOTE_APP_ROOT}/${LIB_DIRECTORY}/executors/execute_backout.sh -a";
        RETURN_CODE=${?};
    fi

    if [ ! ${RETURN_CODE} -eq 0 ]
    then
        ## we got an error back
        ## send it back to the ui
        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "An error occurred while retrieving data. Return code from execute_backout -> ${RET_CODE}";
        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";
    else
        ## clear
        set -A FILE_LIST;

        if [[ ! -z "${LOCAL_EXECUTION}" && "${LOCAL_EXECUTION}" = "${_TRUE}" ]]
        then
            set -A FILE_LIST $(sed -e "s/^M//g" ${PLUGIN_ROOT_DIR}/${BACKUP_LIST});
        else
            set -A FILE_LIST $(${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSSHConnection.exp ${NAMED_MASTER} "sed \"s/^M//g\" ${PLUGIN_ROOT_DIR}/${BACKUP_LIST}");
        fi

        if [ ${#FILE_LIST[@]} -eq 0 ]
        then
            ## an error occurred, we didn't get a file list back
            ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "An error occurred retrieving the file list.";
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

            RETURN_CODE=28;
        else
            ## write the data out to a temp file
            while [ ${A} -ne ${#FILE_LIST[@]} ]
            do
                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "FILE_LIST->${FILE_LIST[${A}]}";
                (( A += 1 ));
            done

            A=0;

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

            RETURN_CODE=0;
        fi
    fi

    return ${RETURN_CODE};
}

#===  FUNCTION  ===============================================================
#          NAME:  runBackoutWithOptions
#   DESCRIPTION:  Processes and implements a DNS site failover
#    PARAMETERS:  Parameters obtained via command-line flags
#          NAME:  usage for positive result, >1 for non-positive
#==============================================================================
function runBackoutWithOptions
{
    [[ ! -z "${TRACE}" && "${TRACE}" = "${_TRUE}" ]] && set -x;
    local METHOD_NAME="${CNAME}#${0}";

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";
    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing backout procedure for ${FILE_NAME}..";

    if [[ ! -z "${LOCAL_EXECUTION}" && "${LOCAL_EXECUTION}" = "${_TRUE}" ]]
    then
        if [[ ! -z "${TRACE}" && "${TRACE}" = "${_TRUE}" ]]
        then
            exec ksh -v -x ${PLUGIN_ROOT_DIR}/${LIB_DIRECTORY}/executors/execute_backout.sh -b ${BUSINESS_UNIT} -c ${CHANGE_NUM} -d ${CHANGE_DATE} -e;
        else
            . ${PLUGIN_ROOT_DIR}/${LIB_DIRECTORY}/executors/execute_backout.sh -b ${BUSINESS_UNIT} -c ${CHANGE_NUM} -d ${CHANGE_DATE} -e;
        fi
    else
        ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSSHConnection.exp ${NAMED_MASTER} "${REMOTE_APP_ROOT}/${LIB_DIRECTORY}/executors/execute_backout.sh -b ${BUSINESS_UNIT} -c ${CHANGE_NUM} -d ${CHANGE_DATE} -e";
    fi

    ## capture the return code
    RETURN_CODE=${?};

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Execution complete. Return code->${RETURN_CODE}";

    if [ ${RETURN_CODE} -eq 0 ]
    then
        ## successfully processed backout request. we're going to audit log it and then
        ## reload config on the master.
        unset RETURN_CODE;

        ## ok our logging is done. reload config.
        . ${PLUGIN_ROOT_DIR}/${LIB_DIRECTORY}/runRNDCCommands.sh -c reload -e;
        RETURN_CODE=${?};

        if [ ${RETURN_CODE} -eq 0 ]
        then
            ## we've applied and activated our change. reload changes into the configured
            ## slave servers
            ${LOGGER} AUDIT "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backout of change order ${CHANGE_NUM}, business unit ${BUSINESS_UNIT}, change date ${CHANGE_DATE} has been processed by ${IUSER_AUDIT} on $(date +"%Y-%m-%dT%H:%M:%S")";
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Change successfully validated on ${NAMED_MASTER}. Processing against slaves..";

            ## make sure that we have slaves to operate against
            if [ ${#DNS_SLAVES[@]} -ne 0 ]
            then
                ## we have slaves to process against. do so.
                ## make sure D is 0, ERROR_COUNT is 0
                D=0;
                ERROR_COUNT=0;

                while [ ${D} -ne ${#DNS_SLAVES[@]} ]
                do
                    ## temp unset
                    unset METHOD_NAME;
                    unset CNAME;

                    ## send an rndc reload to the server to make it active
                    . ${PLUGIN_ROOT_DIR}/${LIB_DIRECTORY}/runRNDCCommands.sh -s ${DNS_SLAVE[${D}]} -c reload -e;
                    RETURN_CODE=${?};

                    if [ ${RETURN_CODE} -eq 0 ]
                    then
                        ## config reload succeeded
                        unset RETURN_CODE;
                        ${LOGGER} "INFO" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Successfully reloaded configuration on ${DNS_SLAVES[${D}]}.";
                    else
                        ## rndc request failed.
                        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to reload new configuration on ${DNS_SLAVES[${D}]}.";

                        (( ERROR_COUNT += 1 ));
                        set -A FAILED_SERVERS ${FAILED_SERVERS[@]} ${DNS_SLAVES[${D}]};
                    fi

                    ## increment d and unset the return code
                    (( D += 1 ));
                    unset RETURN_CODE;
                done
            else
                ## we have no slaves to operate against. return success since the servers we have
                ## are done
                RETURN_CODE=0;
            fi
        else
            ## failed to validate that the change was successfully implemented. either the
            ## reload failed or we didnt have the right/enough information to perform
            ## the validation
            ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to reload new configuration on ${NAMED_MASTER}.";

            RETURN_CODE=61;
        fi
    elif [ ${RETURN_CODE} -eq 27 ]
    then
        ## multiple backup files exist for the lookup provided
        if [[ ! -z "${LOCAL_EXECUTION}" && "${LOCAL_EXECUTION}" = "${_TRUE}" ]]
        then
            set -A BACKUP_FILES $(cat ${PLUGIN_ROOT_DIR}/${BACKUP_LIST});
        else
            set -A BACKUP_FILES $(${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSSHConnection.exp ${NAMED_MASTER} "sed \"s/^M//g\" ${PLUGIN_ROOT_DIR}/${BACKUP_LIST}");
        fi

        if [ ${VERBOSE} ]
        then
            while [ ${A} -ne ${#BACKUP_FILES[@]} ]
            do
                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "BACKUP_FILES->${BACKUP_FILES[${A}]}";
                (( A += 1 ));
            done

            A=0;
        fi
    else
        ## our backout processing has failed.
        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backout execution for business unit ${BUSINESS_UNIT}, change order ${CHANGE_NUM}, and date ${CHANGE_DATE} has FAILED on ${NAMED_MASTER}.";

        RETURN_CODE=${RETURN_CODE};
    fi

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

    return ${RETURN_CODE};
}

#===  FUNCTION  ===============================================================
#          NAME:  runBackoutWithFileName
#   DESCRIPTION:  Processes and implements a DNS site failover
#    PARAMETERS:  Parameters obtained via command-line flags
#          NAME:  usage for positive result, >1 for non-positive
#==============================================================================
function runBackoutWithFileName
{
    [[ ! -z "${TRACE}" && "${TRACE}" = "${_TRUE}" ]] && set -x;
    local METHOD_NAME="${CNAME}#${0}";

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";
    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing backout procedure for ${FILE_NAME}..";

    if [[ ! -z "${LOCAL_EXECUTION}" && "${LOCAL_EXECUTION}" = "${_TRUE}" ]]
    then
        if [[ ! -z "${TRACE}" && "${TRACE}" = "${_TRUE}" ]]
        then
            exec ksh -v -x ${PLUGIN_ROOT_DIR}/${LIB_DIRECTORY}/executors/execute_backout.sh -f ${FILE_NAME};
        else
            . ${PLUGIN_ROOT_DIR}/${LIB_DIRECTORY}/executors/execute_backout.sh -f ${FILE_NAME};
        fi
    else
        ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSSHConnection.exp ${NAMED_MASTER} "${REMOTE_APP_ROOT}/${LIB_DIRECTORY}/executors/execute_backout.sh -f ${FILE_NAME}";
    fi

    ## capture the return code
    RETURN_CODE=${?};

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Execution complete. Return code->${RETURN_CODE}";

    if [ ${RETURN_CODE} -eq 0 ]
    then
        ## successfully processed backout request. we're going to audit log it and then
        ## reload config on the master.
        unset RETURN_CODE;

        ## ok our logging is done. reload config.
        . ${PLUGIN_ROOT_DIR}/${LIB_DIRECTORY}/runRNDCCommands.sh -c reload -e;
        RETURN_CODE=${?};

        if [ ${RETURN_CODE} -eq 0 ]
        then
            ## we've applied and activated our change. reload changes into the configured
            ## slave servers
            ${LOGGER} AUDIT "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backout of change order ${CHANGE_NUM}, business unit ${BUSINESS_UNIT}, change date ${CHANGE_DATE} has been processed by ${IUSER_AUDIT} on $(date +"%Y-%m-%dT%H:%M:%S")";
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Change successfully validated on ${NAMED_MASTER}. Processing against slaves..";

            ## make sure that we have slaves to operate against
            if [ ${#DNS_SLAVES[@]} -ne 0 ]
            then
                ## we have slaves to process against. do so.
                ## make sure D is 0, ERROR_COUNT is 0
                D=0;
                ERROR_COUNT=0;

                while [ ${D} -ne ${#DNS_SLAVES[@]} ]
                do
                    ## temp unset
                    unset METHOD_NAME;
                    unset CNAME;

                    ## send an rndc reload to the server to make it active
                    . ${PLUGIN_ROOT_DIR}/${LIB_DIRECTORY}/runRNDCCommands.sh -s ${DNS_SLAVE[${D}]} -c reload -e;
                    RETURN_CODE=${?};

                    if [ ${RETURN_CODE} -eq 0 ]
                    then
                        ## config reload succeeded
                        unset RETURN_CODE;
                        ${LOGGER} "INFO" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Successfully reloaded configuration on ${DNS_SLAVES[${D}]}.";
                    else
                        ## rndc request failed.
                        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to reload new configuration on ${DNS_SLAVES[${D}]}.";

                        (( ERROR_COUNT += 1 ));
                        set -A FAILED_SERVERS ${FAILED_SERVERS[@]} ${DNS_SLAVES[${D}]};
                    fi

                    ## increment d and unset the return code
                    (( D += 1 ));
                    unset RETURN_CODE;
                done
            else
                ## we have no slaves to operate against. return success since the servers we have
                ## are done
                RETURN_CODE=0;
            fi
        else
            ## failed to validate that the change was successfully implemented. either the
            ## reload failed or we didnt have the right/enough information to perform
            ## the validation
            ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to reload new configuration on ${NAMED_MASTER}.";

            RETURN_CODE=61;
        fi
    else
        ## our backout processing has failed.
        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backout execution for file ${FILE_NAME} has FAILED on ${NAMED_MASTER}.";

        RETURN_CODE=${RETURN_CODE};
    fi

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

    return ${RETURN_CODE};
}

#===  FUNCTION  ===============================================================
#          NAME:  usage
#   DESCRIPTION:  Provide information on the function usage of this application
#    PARAMETERS:  None
#   RETURNS:  0
#==============================================================================
function usage
{
    [[ ! -z "${TRACE}" && "${TRACE}" = "${_TRUE}" ]] && set -x;
    local METHOD_NAME="${CNAME}#${0}";

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";

    print "${CNAME} - Perform a backout for a previously executed change";
    print "Usage: ${CNAME} [-a] [-f filename] [-b business unit] [-d date] [-c change request] [-e execute] [-?|-h show this help]";
    print "  -a      Retrieve a list of all backout files";
    print "  -f      Perform a backout using the specified backout file";
    print "  -b      The business unit associated with the change request";
    print "  -d      The date the change request was performed";
    print "  -c      The change order associated with this request";
    print "  -e      Execute processing";
    print "  -h|-?   Show this help";

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

    return 3;
}

while getopts ":af:b:d:c:eh:" OPTIONS
do
    case "${OPTIONS}" in
        a)
            ## retrieve a list of all available zone files
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";

            ## Capture the site root
            obtainBackoutList;

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";
            ;;
        f)
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting FILE_NAME..";

            ## Capture the site root
            FILE_NAME="${OPTARG}";

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

            ## we were given a filename, process it
            runBackoutWithFileName;
            ;;
        b)
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting BUSINESS_UNIT..";

            ## Capture the filename to work on
            typeset -u BUSINESS_UNIT="${OPTARG}";

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "BUSINESS_UNIT -> ${BUSINESS_UNIT}";
            ;;
        d)
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting CHANGE_DATE..";

            ## Capture the target datacenter
            CHANGE_DATE="${OPTARG}";

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CHANGE_DATE -> ${CHANGE_DATE}";
            ;;
        c)
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting CHANGE_NUM..";

            ## Capture the change control
            typeset -u CHANGE_NUM="${OPTARG}";

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CHANGE_NUM -> ${CHANGE_NUM}";
            ;;
        e)
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Validating request..";

            ## Make sure we have enough information to process
            ## and execute
            if [ -z "${BUSINESS_UNIT}" ]
            then
                ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No target datacenter was provided. Unable to continue processing.";
                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                RETURN_CODE=15;
            elif [ -z "${IUSER_AUDIT}" ]
            then
                ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "The requestors username was not provided. Unable to continue processing.";
                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                RETURN_CODE=20;
            elif [ -z "${CHANGE_NUM}" ]
            then
                ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No change control number was provided. Unable to continue processing.";
                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                RETURN_CODE=19;
            else
                ## We have enough information to process the request, continue
                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Request validated - executing";
                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                runBackoutWithOptions;
            fi
            ;;
        h|[\?])
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

            usage;
            ;;
        *)
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

            usage;
            ;;
    esac
done

shift $OPTIND-1;

return ${RETURN_CODE};
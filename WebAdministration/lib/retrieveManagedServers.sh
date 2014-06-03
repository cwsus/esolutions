#!/usr/bin/env ksh
#==============================================================================
#
#          FILE:  retrieveManagedServers.sh
#         USAGE:  ./retrieveManagedServers.sh server_name
#   DESCRIPTION:  Connects to the provided DNS server and restarts the named
#                 process. Utilized to apply pending changes, or to recycle
#                 the service if required for any other reason.
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  Kevin Huntly <kmhuntly@gmail.com
#       COMPANY:  CaspersBox Web Services
#       VERSION:  1.0
#       CREATED:  ---
#      REVISION:  ---
#==============================================================================
## Application constants
CNAME="$(basename "${0}")";
SCRIPT_ABSOLUTE_PATH="$(cd "${0%/*}" 2>/dev/null; echo "${PWD}"/"${0##*/}")";
SCRIPT_ROOT="$(dirname "${SCRIPT_ABSOLUTE_PATH}")";

#===  FUNCTION  ===============================================================
#          NAME:  obtainManagedServerList
#   DESCRIPTION:  Processes and implements a DNS site failover
#    PARAMETERS:  Parameters obtained via command-line flags
#       RETURNS:  0 for positive result, >1 for non-positive
#==============================================================================
function obtainManagedServerList
{
    [[ ! -z "${TRACE}" && "${TRACE}" = "${_TRUE}" ]] && set -x;
    local METHOD_NAME="${CNAME}#${0}";

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";
    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Retrieving managed server list..";

    ## pull out a list of servers
    for SERVER in $(getMachineInfo | grep -v "^#" | grep WEB | grep sol8 | cut -d "|" -f 1 | sort | uniq; \
        getMachineInfo | grep -v "^#" | grep WEB | grep sol9 | cut -d "|" -f 1 | sort | uniq; \
        getMachineInfo | grep -v "^#" | grep WEB | grep sol10 | cut -d "|" -f 1 | sort | uniq;)
    do
        if [ $(echo ${SERVER_IGNORE_LIST} | grep -c ${SERVER}) == 0 ]
        then
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Adding ${SERVER} to MANAGED_SERVERS..";

            set -A MANAGED_SERVERS ${MANAGED_SERVERS[@]} ${SERVER};
        else
            ## server found in exclusion list
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${SERVER} was found in exclusion list. Skippiing.";
        fi
    done

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "MANAGED_SERVERS -> ${MANAGED_SERVERS[@]}";

    if [ ! -z "${MANAGED_SERVERS}" ]
    then
        ## at least one website was found and returned for validation
        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Managed servers listed and returned.";

        echo ${MANAGED_SERVERS[@]};

        RETURN_CODE=0;
    else
        ## no web instances were found or no urlhosts were identified
        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "MANAGED_SERVERS was found to be empty. Cannot continue.";

        RETURN_CODE=1;
    fi

    unset SERVER;
    unset MANAGED_SERVERS;

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";
}

[[ -z "${PLUGIN_ROOT_DIR}" && -s ${SCRIPT_ROOT}/../lib/${PLUGIN_NAME}.sh ]] && . ${SCRIPT_ROOT}/../lib/${PLUGIN_NAME}.sh;
[ -z "${PLUGIN_ROOT_DIR}" ] && exit 1

METHOD_NAME="${CNAME}#startup";

[[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${CNAME} starting up.. Process ID ${$}";
[[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Provided arguments: ${@}";
[[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";

obtainManagedServerList;

exit ${RETURN_CODE};
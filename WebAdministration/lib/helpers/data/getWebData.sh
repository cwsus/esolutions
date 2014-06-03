#!/usr/bin/env ksh
#==============================================================================
#
#          FILE:  run_key_generation.sh
#         USAGE:  ./run_key_generation.sh
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
CNAME="$(basename "${0}")";
SCRIPT_ABSOLUTE_PATH="$(cd "${0%/*}" 2>/dev/null; echo "${PWD}"/"${0##*/}")";
SCRIPT_ROOT="$(dirname "${SCRIPT_ABSOLUTE_PATH}")";

#===  FUNCTION  ===============================================================
#          NAME:  obtainWebData
#   DESCRIPTION:  Generates a certificate signing request (CSR) for an iPlanet
#                 webserver
#    PARAMETERS:  None
#       RETURNS:  0
#==============================================================================
function obtainWebData
{
    [[ ! -z "${TRACE}" && "${TRACE}" = "${_TRUE}" ]] && set -x;
    local METHOD_NAME="${CNAME}#${0}";

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";

    if [ $(getWebInfo | grep -w ${SITE_HOSTNAME} | wc -l) != 0 ]
    then
        ## we've been provided a hostname, lets get the data from esupport
        ## this sets up the project code
        ## first, the stuff out of URL_Defs
        WEB_PROJECT_CODE=$(getWebInfo | grep -w ${SITE_HOSTNAME} | grep -v "#" | \
            cut -d "|" -f 1 | cut -d ":" -f 2 | sort | uniq); ## get the webcode
        PLATFORM_CODE=$(getWebInfo | grep "${SITE_HOSTNAME}" | grep -v "#" | \
            cut -d "|" -f 2 | sort | uniq | tr "[\n]" "[ ]"); ## get the platform code, if multiples spit with space
        MASTER_WEBSERVER=$(getPlatformInfo | grep -w $(echo ${PLATFORM_CODE} | awk '{print $1}') | \
            grep -v "#" | cut -d "|" -f 5 | sort | uniq | sed -e "s/,/ /g" | awk '{print $1}');
        [ "$(getWebInfo | grep -w ${WEB_PROJECT_CODE} | grep -v "#" | grep "${SITE_HOSTNAME}" | \
            cut -d "|" -f 10 | sort | uniq | grep enterprise)" = "" ] \
            && WEBSERVER_PLATFORM=${IHS_TYPE_IDENTIFIER} \
            || WEBSERVER_PLATFORM=${IPLANET_TYPE_IDENTIFIER};
        ENVIRONMENT_TYPE=$(getWebInfo | grep -w ${WEB_PROJECT_CODE} | grep -v "#" | grep "${SITE_HOSTNAME}" | \
            cut -d "|" -f 3 | sort | uniq); ## the environment type (dev, ist etc) TODO: fix this cut, it isnt right
        SERVER_ROOT=$(getWebInfo | grep -w ${WEB_PROJECT_CODE} | grep -v "#" | grep "${SITE_HOSTNAME}" | \
            cut -d "|" -f 10 | cut -d "/" -f 1-3 | sort | uniq); ## web instance name
        CONTACT_CODE=$(getWebInfo | grep -w ${SITE_HOSTNAME} | grep -v "#" | \
            cut -d "|" -f 14 | cut -d ":" -f 2 | sort | uniq); ## get the contact code
        OWNER_DIST=$(getContactInfo | grep -w ${CONTACT_CODE} | grep -v "#" | \
            cut -d "|" -f 7 | sort | uniq); ## get the contact dist list

        ## make sure we have a valid and supported platform
        if [ "${WEBSERVER_PLATFORM}" != "${IPLANET_TYPE_IDENTIFIER}" ] \
            && [ "${WEBSERVER_PLATFORM}" != "${IHS_TYPE_IDENTIFIER}" ]
        then
            ## unsupported platform
            ## unset SVC_LIST, we dont need it now
            unset REQUEST_OPTION;
            unset SITE_HOSTNAME;
            unset WEB_PROJECT_CODE;
            unset PLATFORM_CODE;
            unset MASTER_WEBSERVER;
            unset ENVIRONMENT_TYPE;
            unset SERVER_ROOT;
            unset CONTACT_CODE;
            unset OWNER_DIST;

            ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Unsupported platform detected - Renewal process aborted";

            DATA_CODE=41;
        else
            if [ "${WEBSERVER_PLATFORM}" = "${IPLANET_TYPE_IDENTIFIER}" ]
            then
                INSTANCE_NAME=$(getWebInfo | grep -w ${WEB_PROJECT_CODE} | grep -v "#" | grep "${SITE_HOSTNAME}" | \
                    cut -d "|" -f 10 | cut -d "/" -f 4 | sort | uniq); ## web instance name
            elif [ "${WEBSERVER_PLATFORM}" = "${IHS_TYPE_IDENTIFIER}" ]
            then
                INSTANCE_NAME=$(getWebInfo | grep -w ${WEB_PROJECT_CODE} | grep -v "#" | grep "${SITE_HOSTNAME}" | \
                    cut -d "|" -f 10 | cut -d "/" -f 5 | sort | uniq); ## web instance name
            fi

            CERTDB=${INSTANCE_NAME}-${IUSER_AUDIT}-;

            if [ "${ENVIRONMENT_TYPE}" = "${ENV_TYPE_PRD}" ]
            then
                ## find out where its live right now
                unset METHOD_NAME;
                unset CNAME;
                unset RET_CODE;

                . ${APP_ROOT}/lib/runQuery.sh -u ${SITE_HOSTNAME} -e;
                RET_CODE=${?}

                CNAME=$(basename ${0});
                [[ ! -z "${TRACE}" && "${TRACE}" = "${_TRUE}" ]] && set -x;
    local METHOD_NAME="${CNAME}#${0}";

                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "ACTIVE_DATACENTER -> ${ACTIVE_DATACENTER}";
                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";

                DATA_CODE=0;

                if [ ! -z "${ACTIVE_DATACENTER}" ] && [ ${RET_CODE} == 0 ]
                then
                    unset RET_CODE;
                    unset RETURN_CODE;

                    ## we have an active datacenter, re-order the server list
                    PRI_PLATFORM_CODE=$(getWebInfo | grep "${SITE_HOSTNAME}" | grep -v "#" | grep -v ${ACTIVE_DATACENTER} | \
                        cut -d "|" -f 2 | sort | uniq); ## get the platform code, if multiples spit with space
                    SEC_PLATFORM_CODE=$(getWebInfo | grep "${SITE_HOSTNAME}" | grep -v "#" | grep ${ACTIVE_DATACENTER} | \
                        cut -d "|" -f 2 | sort | uniq); ## get the platform code, if multiples spit with space

                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PRI_PLATFORM_CODE -> ${PRI_PLATFORM_CODE}";
                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "SEC_PLATFORM_CODE -> ${SEC_PLATFORM_CODE}";

                    DATA_CODE=0;
                else
                    ## unable to accurately determine current datacenter
                    ## return a warning
                    ${LOGGER} "WARN" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Active datacenter could not be established.";

                    DATA_CODE=91;
                fi
            fi
        fi
    else
        ## unable to find data
        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to locate configuration data in ${EINFO_WEBSITE_DEFS}. Cannot continue.";

        DATA_CODE=42;
    fi

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";
}

#===  FUNCTION  ===============================================================
#      NAME:  usage
#   DESCRIPTION:  Provide information on the usage of this application
#    PARAMETERS:  None
#   RETURNS:  0
#==============================================================================
usage
{
    METHOD_NAME="${CNAME}#usage";

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";

    print "${CNAME} - Generates a certificate signing request for a provided host.";
    print " -s    -> The site domain name to operate against";
    print " -v    -> The source server to obtain the necessary key databases from";
    print " -w    -> Platform type to execute against - iplanet or ihs";
    print " -p    -> The webserver base path (e.g. /opt/IBMIHS70)";
    print " -d    -> The certificate database to work against";
    print " -c    -> The target platform code.";
    print " -t    -> The requestor telephone number";
    print " -e    -> Execute the request";
    print " -h|-? -> Show this help";

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

    return 3;
}

[[ -z "${PLUGIN_ROOT_DIR}" && -s ${SCRIPT_ROOT}/../lib/${PLUGIN_NAME}.sh ]] && . ${SCRIPT_ROOT}/../lib/${PLUGIN_NAME}.sh;
[ -z "${PLUGIN_ROOT_DIR}" ] && exit 1

[ ${#} -eq 0 ] && usage;

METHOD_NAME="${CNAME}#startup";

[[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${CNAME} starting up.. Process ID ${$}";
[[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Provided arguments: ${@}";
[[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";

obtainWebData "${@}";

return ${DATA_CODE};

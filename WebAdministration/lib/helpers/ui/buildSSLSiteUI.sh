#!/usr/bin/env ksh
#==============================================================================
#
#          FILE:  certRenewalUI.sh.sh
#         USAGE:  ./certRenewalUI.sh.sh
#   DESCRIPTION:  Helper interface for add_record_ui. Pluggable, can be modified
#                 or copied for all allowed record types.
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
#          NAME:  buildSSLSite
#   DESCRIPTION:  Processes requests to add additional record types to a zone
#    PARAMETERS:  None
#       RETURNS:  0
#==============================================================================
function buildSSLSite
{
    [[ ! -z "${TRACE}" && "${TRACE}" = "${_TRUE}" ]] && set -x;
    local METHOD_NAME="${CNAME}#${0}";

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";
    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Buildout SSL-enabled website ..";

    trap "print '$(grep system.trap.signals "${SYSTEM_MESSAGES}" | grep -v "#" | cut -d "=" -f 2 | sed -e "s/%SIGNAL%/Ctrl-C/")'; sleep ${MESSAGE_DELAY}; reset; clear; continue " 1 2 3

    while true
    do
        if [ ! -z "${BUILD_COMPLETE}" ] && [ "${BUILD_COMPLETE}" = "${_TRUE}" ]
        then
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Received request to break out. ADD_RECORDS->${ADD_RECORDS}, CANCEL_REQ->${CANCEL_REQ}.";

            break;
        fi

        reset; clear;

        print "\t\t\t$(grep -w system.application.title "${PLUGIN_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)\n";
        print "\t\t\t$(grep -w createsite.application.title "${PLUGIN_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)\n";
        print "\t$(grep -w createsite.provide.sslport "${PLUGIN_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)";
        print "\t$(grep -w system.option.cancel "${SYSTEM_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)\n";

        read SSL_PORTNUM;

        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "SSL_PORTNUM -> ${SSL_PORTNUM}";

        reset; clear;

        print "$(grep -w system.pending.message "${SYSTEM_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)\n";

        case ${SSL_PORTNUM} in
            [Xx]|[Qq]|[Cc])
                unset SITE_HOSTNAME;

                ## user opted to cancel, remove the lockfile
                if [ -f ${APP_ROOT}/${APP_FLAG} ]
                then
                    rm -rf ${APP_ROOT}/${APP_FLAG};
                fi

                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failover process aborted";

                print "$(grep -w system.request.canceled "${SYSTEM_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)\n";

                ## unset SVC_LIST, we dont need it now
                unset SVC_LIST;

                ## terminate this thread and return control to main
                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                ## temporarily unset stuff
                unset METHOD_NAME;
                unset CNAME;

                sleep "${MESSAGE_DELAY}"; reset; clear;

                exec ${APP_ROOT}/${MAIN_CLASS} -c;

                exit 0;
                ;;
            *)
                if [ "$(isNaN ${SSL_PORTNUM})" = "${_TRUE}" ]
                then
                    if [ ${SSL_PORTNUM} -gt 65535 ]
                    then
                        ## port number invalid
                        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "An invalid port number was provided.";

                        print "$(grep -w selection.invalid "${ERROR_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)\n";

                        ## unset SVC_LIST, we dont need it now
                        unset PORT_CONFIRMATION;
                        unset SSL_PORTNUM;
                        IS_PORT_VALID=${_FALSE};

                        sleep "${MESSAGE_DELAY}"; reset; clear; break;
                    elif [ ${SSL_PORTNUM} -le ${HIGH_PRIVILEGED_PORT} ]
                    then
                        ## user is requesting a privileged port - confirm
                        while true
                        do
                            reset; clear;

                            print "\t\t\t$(grep -w system.application.title "${PLUGIN_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)\n";
                            print "\t\t\t$(grep -w createsite.application.title "${PLUGIN_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)\n";
                            print "\t$(grep -w createsite.privileged.port "${PLUGIN_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)";
                            
                            read PORT_CONFIRMATION;

                            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PORT_CONFIRMATION -> ${PORT_CONFIRMATION}";

                            reset; clear;

                            print "$(grep -w system.pending.message "${SYSTEM_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)\n";

                            case ${PORT_CONFIRMATION} in
                                [Yy][Ee][Ss]|[Yy])
                                    reset; clear; break;

                                    IS_PORT_VALID=${_TRUE};
                                    ;;
                                [Nn][Oo]|[Nn])
                                    reset; clear;

                                    unset PORT_CONFIRMATION;
                                    unset SSL_PORTNUM;

                                    IS_PORT_VALID=${_FALSE};

                                    reset; clear; break;
                                    ;;
                                *)
                                    ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "An invalid response was provided.";

                                    print "$(grep -w selection.invalid "${ERROR_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)\n";

                                    ## unset SVC_LIST, we dont need it now
                                    unset PORT_CONFIRMATION;

                                    sleep "${MESSAGE_DELAY}"; reset; clear; continue;
                                    ;;
                            esac
                        done
                    else
                        IS_PORT_VALID=${_TRUE};
                    fi

                    if [ ! -z "${IS_PORT_VALID}" ] && [ "${IS_PORT_VALID}" = "${_TRUE}" ]
                    then
                        ## great, lets make sure its not already in use
                        . ${APP_ROOT}/lib/validators/validatePortNumber.sh ${SSL_PORTNUM};
                        RET_CODE=${?};

                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";

                        if [ ! -z "${RET_CODE}" ] && [ ${RET_CODE} == 0 ]
                        then
                            ## good, port number is valid
                            ## get websphere info (if any)
                            while true
                            do
                                reset; clear;

                                print "\t\t\t$(grep -w system.application.title "${PLUGIN_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)\n";
                                print "\t\t\t$(grep -w createsite.application.title "${PLUGIN_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)\n";
                                print "\t$(grep -w createsite.enable.websphere "${PLUGIN_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)";
                                print "\t$(grep -w system.option.cancel "${SYSTEM_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)\n";

                                read ENABLE_WEBSPHERE;

                                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "ENABLE_WEBSPHERE -> ${ENABLE_WEBSPHERE}";

                                reset; clear;

                                print "$(grep -w system.pending.message "${SYSTEM_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)\n";

                                case ${ENABLE_WEBSPHERE} in
                                    [Xx]|[Qq]|[Cc])
                                        unset ENABLE_WEBSPHERE;

                                        ## user opted to cancel, remove the lockfile
                                        if [ -f ${APP_ROOT}/${APP_FLAG} ]
                                        then
                                            rm -rf ${APP_ROOT}/${APP_FLAG};
                                        fi

                                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failover process aborted";

                                        print "$(grep -w system.request.canceled "${SYSTEM_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)\n";

                                        ## terminate this thread and return control to main
                                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                        ## temporarily unset stuff
                                        unset METHOD_NAME;
                                        unset CNAME;

                                        sleep "${MESSAGE_DELAY}"; reset; clear;

                                        exec ${APP_ROOT}/${MAIN_CLASS} -c;

                                        exit 0;
                                        ;;
                                    [Yy][Ee][Ss]|[Yy])
                                        ## websphere-enabled site. get the vhost
                                        ## re-define ENABLE_WEBSPHERE
                                        ENABLE_WEBSPHERE=${_TRUE};

                                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "ENABLE_WEBSPHERE -> ${ENABLE_WEBSPHERE}";

                                        reset; clear; break;
                                        ;;
                                    [Nn][Oo]|[Nn])
                                        ## ok. at this point we have enough to work with. start building
                                        ENABLE_WEBSPHERE=${_FALSE};

                                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "ENABLE_WEBSPHERE -> ${ENABLE_WEBSPHERE}";

                                        reset; clear; break;
                                        ;;
                                    *)
                                        ## port number provided isnt a number
                                        reset; clear;

                                        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "A valid response was not provided.";

                                        print "$(grep -w selection.invalid "${ERROR_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)\n";

                                        ## unset SVC_LIST, we dont need it now
                                        unset SSL_PORTNUM;

                                        sleep "${MESSAGE_DELAY}"; reset; clear; continue;
                                        ;;
                                esac
                            done

                            if [ ! -z "${ENABLE_WEBSPHERE}" ]
                            then
                                reset; clear;

                                print "$(grep -w system.pending.message "${SYSTEM_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)\n";

                                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command createWebInstance.sh ${BUILD_TYPE_SSL} ..";

                                . ${APP_ROOT}/lib/createWebInstance.sh ${BUILD_TYPE_SSL};
                                RET_CODE=${?};

                                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";

                                reset; clear;

                                if [ ${RET_CODE} == 0 ]
                                then
                                    BUILD_COMPLETE=${_TRUE};

                                    print "\t\t\t$(grep -w system.application.title "${PLUGIN_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)\n";
                                    print "\t\t\t$(grep -w createsite.application.title "${PLUGIN_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)\n";
                                    print "\t$(grep createsite.build.complete "${PLUGIN_MESSAGES}" | grep -v "#" | cut -d "=" -f 2 | sed -e "s/%SITE_HOSTNAME%/${SITE_HOSTNAME}/")\n";
                                    print "\n\n\t$(grep -w system.continue.enter "${SYSTEM_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)";

                                    read INPUT;

                                    reset; clear; break;
                                else
                                    BUILD_COMPLETE=${_TRUE};

                                    print "\t\t\t$(grep -w system.application.title "${PLUGIN_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)\n";
                                    print "\t\t\t$(grep -w createsite.application.title "${PLUGIN_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)\n";
                                    print "\t$(grep ${RET_CODE} "${PLUGIN_ERROR_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)\n";
                                    print "\n\n\t$(grep -w system.continue.enter "${SYSTEM_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)";

                                    read INPUT;

                                    reset; clear; break;
                                fi
                            else
                                ## missing variable, cant continue
                                ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No response was obtained for ENABLE_WEBSPHERE.";

                                print "$(grep -w selection.invalid "${ERROR_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)\n";

                                ## unset SVC_LIST, we dont need it now
                                unset SSL_PORTNUM;

                                sleep "${MESSAGE_DELAY}"; reset; clear; continue;
                            fi
                        else
                            ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Port number provided is already in use.";

                            print "$(grep -w provided.port.already.used -e "${PLUGIN_ERROR_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)\n";

                            ## unset SVC_LIST, we dont need it now
                            unset SSL_PORTNUM;

                            sleep "${MESSAGE_DELAY}"; reset; clear; continue;
                        fi
                    fi
                else
                    ## port number provided isnt a number
                    ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Provided port number, ${SSL_PORTNUM}, is not a number.";

                    print "$(grep -w selection.invalid "${ERROR_MESSAGES}" | grep -v "#" | cut -d "=" -f 2)\n";

                    ## unset SVC_LIST, we dont need it now
                    unset SSL_PORTNUM;

                    sleep "${MESSAGE_DELAY}"; reset; clear; continue;
                fi
                ;;
        esac
    done

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";
}

METHOD_NAME="${CNAME}#startup";

[[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${CNAME} starting up.. Process ID $$";
[[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Provided arguments: ${@}";
[[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";

buildSSLSite;

#!/usr/bin/env ksh
#==============================================================================
#
#          FILE:  runMonitor.sh
#         USAGE:  ./runMonitor.sh monitor-name
#   DESCRIPTION:  Executes the requested monitoring script across the known web
#                 servers.
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
#          NAME:  executeMonitoringScript
#   DESCRIPTION:  Processes and implements a DNS site failover
#    PARAMETERS:  Parameters obtained via command-line flags
#       RETURNS:  0 for positive result, >1 for non-positive
#==============================================================================
function executeMonitoringScript
{
    [[ ! -z "${TRACE}" && "${TRACE}" = "${_TRUE}" ]] && set -x;
    local METHOD_NAME="${CNAME}#${0}";

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";
    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing monitor on: ${HOSTNAME}";

    ## clean up the output file
    echo "" > ${APP_ROOT}/${TMP_DIRECTORY}/${MONITOR_OUTPUT_FILE};

    ## set up our execution date
    EXECUTION_DATE=$(date +"%d %b %Y");

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "EXECUTION_DATE -> ${EXECUTION_DATE}";

    if [ ! -z "${TARGET_SYSTEM}" ]
    then
        ## we were asked to monitor on a specific server - execute
        for MONITORED_HOST in ${TARGET_SYSTEM}
        do
            if [ $(echo ${SERVER_IGNORE_LIST} | grep -c ${MONITORED_HOST}) == 0 ]
            then
                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Now operating against ${MONITORED_HOST}..";
                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Now validating access..";

                $(ping ${MONITORED_HOST} > /dev/null 2>&1);

                PING_RCODE=${?}

                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PING_RCODE -> ${PING_RCODE}";

                if [ ${PING_RCODE} == 0 ]
                then
                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command runSSHConnection.exp ${MONITORED_HOST} \"${REMOTE_APP_ROOT}/lib/monitors/${MONITORING_SCRIPT}.sh ${EXPIRY_EPOCH}\" ${IPLANET_OWNING_USER} ${MONITOR_THREAD_TIMEOUT}";

                    ## unset ret code from prior execution
                    unset RET_CODE;
    
                    $(${APP_ROOT}/lib/tcl/runSSHConnection.exp ${MONITORED_HOST} "${REMOTE_APP_ROOT}/lib/monitors/${MONITORING_SCRIPT}.sh ${EXPIRY_EPOCH}" ${IPLANET_OWNING_USER} ${MONITOR_THREAD_TIMEOUT});
                    RET_CODE=${?};
        
                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";
        
                    if [ ${RET_CODE} == 0 ]
                    then
                        ## command execution was successful. lets see if the monitor log is empty,
                        ## if not, pull it back
                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Command execution successful. Checking for anomolies..";
        
                        IS_LOGFILE_PRESENT=$(${APP_ROOT}/lib/tcl/runSSHConnection.exp ${MONITORED_HOST} "[ -s ${REMOTE_APP_ROOT}/${LOG_ROOT}/${BASE_LOG_NAME}-${MONITOR_RECORDER} ] && echo true || echo false" ${IPLANET_OWNING_USER});
        
                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "IS_LOGFILE_PRESENT -> ${IS_LOGFILE_PRESENT}";
        
                        if [ ! -z "${IS_LOGFILE_PRESENT}" ] && [ "${IS_LOGFILE_PRESENT}" = "${_TRUE}" ]
                        then
                            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Obtaining logfiles..";
        
                            $(${APP_ROOT}/lib/tcl/runSCPConnection.exp remote-copy ${MONITORED_HOST} ${REMOTE_APP_ROOT}/${LOG_ROOT}/${BASE_LOG_NAME}-${MONITOR_RECORDER} ${APP_ROOT}/${TMP_DIRECTORY}/${MONITORED_HOST}.${BASE_LOG_NAME}-${MONITOR_RECORDER} ${IPLANET_OWNING_USER});
        
                            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Logfiles obtained. Scanning..";
    
                            print "${MONITORED_HOST}:\n" >> ${APP_ROOT}/${TMP_DIRECTORY}/${MONITOR_OUTPUT_FILE};
    
                            sed -n "/${MONITORING_SCRIPT}/p" ${APP_ROOT}/${TMP_DIRECTORY}/${MONITORED_HOST}.${BASE_LOG_NAME}-${MONITOR_RECORDER} | \
                                grep "${EXECUTION_DATE}" | cut -d "-" -f 3- | uniq >> ${APP_ROOT}/${TMP_DIRECTORY}/${MONITOR_OUTPUT_FILE};
    
                            print "\n" >> ${APP_ROOT}/${TMP_DIRECTORY}/${MONITOR_OUTPUT_FILE};
                        else
                            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No logfile present - no anomalies found.";
                        fi
                    else
                        ## an error occurred executing the monitor.
                        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "An error occurred executing ${MONITORING_SCRIPT} on ${MONITORED_HOST}. Return code -> ${RET_CODE}";

                        print "1i\n${MONITORED_HOST}: Execution failure. RET_CODE -> ${RET_CODE}.\n\n.\nwq" | ex -s ${APP_ROOT}/${TMP_DIRECTORY}/${MONITOR_OUTPUT_FILE};

                        (( ERROR_COUNT += 1 ));
                    fi
                else
                    ## ping test failure
                    ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${MONITORED_HOST} appears unavailable. PING_RCODE -> ${PING_RCODE}";

                    print "1i\n${MONITORED_HOST}: Connection failure. PING_RCODE -> ${PING_RCODE}.\n\n.\nwq" | ex -s ${APP_ROOT}/${TMP_DIRECTORY}/${MONITOR_OUTPUT_FILE};

                    (( ERROR_COUNT += 1 ));
                fi
            else
                ## server found in exclusion list
                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${MONITORED_HOST} was found in exclusion list. Skippiing.";
            fi
        done
    else
        ## this method will only ever run on an ecom. it'll obtain the list of verifiable sites
        ## and then execute openssl to obtain the current certificate expiration
        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Generating server list...";

        for MONITORED_HOST in $(${APP_ROOT}/lib/retrieveManagedServers.sh)
        do
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Now operating against ${MONITORED_HOST}..";
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Now validating access..";

            $(ping ${MONITORED_HOST} > /dev/null 2>&1);

            PING_RCODE=${?};

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PING_RCODE -> ${PING_RCODE}";

            if [ ${PING_RCODE} == 0 ]
            then
                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command runSSHConnection.exp ${MONITORED_HOST} \"${REMOTE_APP_ROOT}/lib/monitors/${MONITORING_SCRIPT}.sh ${EXPIRY_EPOCH}\" ${IPLANET_OWNING_USER} ${MONITOR_THREAD_TIMEOUT}";

                ## unset ret code from prior execution
                unset RET_CODE;
    
                $(${APP_ROOT}/lib/tcl/runSSHConnection.exp ${MONITORED_HOST} "${REMOTE_APP_ROOT}/lib/monitors/${MONITORING_SCRIPT}.sh ${EXPIRY_EPOCH}" ${IPLANET_OWNING_USER} ${MONITOR_THREAD_TIMEOUT});
                RET_CODE=${?};
        
                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";
        
                if [ ${RET_CODE} == 0 ]
                then
                    ## command execution was successful. lets see if the monitor log is empty,
                    ## if not, pull it back
                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Command execution successful. Checking for anomolies..";
        
                    IS_LOGFILE_PRESENT=$(${APP_ROOT}/lib/tcl/runSSHConnection.exp ${MONITORED_HOST} "[ -s ${REMOTE_APP_ROOT}/${LOG_ROOT}/${BASE_LOG_NAME}-${MONITOR_RECORDER} ] && echo true || echo false" ${IPLANET_OWNING_USER});
        
                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "IS_LOGFILE_PRESENT -> ${IS_LOGFILE_PRESENT}";
        
                    if [ ! -z "${IS_LOGFILE_PRESENT}" ] && [ "${IS_LOGFILE_PRESENT}" = "${_TRUE}" ]
                    then
                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Obtaining logfiles..";
        
                        $(${APP_ROOT}/lib/tcl/runSCPConnection.exp remote-copy ${MONITORED_HOST} ${REMOTE_APP_ROOT}/${LOG_ROOT}/${BASE_LOG_NAME}-${MONITOR_RECORDER} ${APP_ROOT}/${TMP_DIRECTORY}/${MONITORED_HOST}.${BASE_LOG_NAME}-${MONITOR_RECORDER} ${IPLANET_OWNING_USER});
        
                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Logfiles obtained. Scanning..";
    
                        print "${MONITORED_HOST}:\n" >> ${APP_ROOT}/${TMP_DIRECTORY}/${MONITOR_OUTPUT_FILE};
    
                        sed -n "/${MONITORING_SCRIPT}/p" ${APP_ROOT}/${TMP_DIRECTORY}/${MONITORED_HOST}.${BASE_LOG_NAME}-${MONITOR_RECORDER} | \
                            grep "${EXECUTION_DATE}" | cut -d "-" -f 3- | uniq >> ${APP_ROOT}/${TMP_DIRECTORY}/${MONITOR_OUTPUT_FILE};
    
                        print "\n" >> ${APP_ROOT}/${TMP_DIRECTORY}/${MONITOR_OUTPUT_FILE};
                    else
                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No logfile present - no anomalies found.";
                    fi
                else
                    ## an error occurred executing the monitor.
                    ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "An error occurred executing ${MONITORING_SCRIPT} on ${MONITORED_HOST}. Return code -> ${RET_CODE}";

                    print "1i\n${MONITORED_HOST}: Execution failure. RET_CODE -> ${RET_CODE}.\n\n.\nwq" | ex -s ${APP_ROOT}/${TMP_DIRECTORY}/${MONITOR_OUTPUT_FILE};

                    (( ERROR_COUNT += 1 ));
                fi
            else
                ## ping test failure
                ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${MONITORED_HOST} appears unavailable. PING_RCODE -> ${PING_RCODE}";

                print "1i\n${MONITORED_HOST}: Connection failure. PING_RCODE -> ${PING_RCODE}.\n\n.\nwq" | ex -s ${APP_ROOT}/${TMP_DIRECTORY}/${MONITOR_OUTPUT_FILE};

                (( ERROR_COUNT += 1 ));
            fi
        done
    fi

    ## ok, processing complete - rock out and see if we have anything to send
    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Processing completed. Validating..";
    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "ERROR_COUNT -> ${ERROR_COUNT}";

    if [ -s ${APP_ROOT}/${TMP_DIRECTORY}/${MONITOR_OUTPUT_FILE} ]
    then
        ## we do, run it out
        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Alert notifications obtained. Processing..";

        unset CNAME;
        unset METHOD_NAME;

        case ${MONITORING_SCRIPT} in
            monitorCertificateDatabases|monitorSiteCertificates)
                if [ ! -z "${TARGET_EMAIL}" ]
                then
                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command ${MAILER_CLASS} -m ${ALERT_CERTIFICATE_EMAIL} -t ${NOTIFY_TYPE_ALERT} -a \"${TARGET_EMAIL}\" -e";

                    . ${MAILER_CLASS} -m ${ALERT_CERTIFICATE_EMAIL} -t ${NOTIFY_TYPE_ALERT} -a "${TARGET_EMAIL}" -e;
                else
                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command ${MAILER_CLASS} -m ${ALERT_CERTIFICATE_EMAIL} -t ${NOTIFY_TYPE_ALERT} -e";

                    . ${MAILER_CLASS} -m ${ALERT_CERTIFICATE_EMAIL} -t ${NOTIFY_TYPE_ALERT} -e;
                fi
                ;;
            monitorOptions|monitorWebs)
                if [ ! -z "${TARGET_EMAIL}" ]
                then
                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command ${MAILER_CLASS} -m ${SITE_MONITOR_EMAIL} -t ${NOTIFY_TYPE_ALERT} -a \"${TARGET_EMAIL}\" -e";

                    . ${MAILER_CLASS} -m ${SITE_MONITOR_EMAIL} -t ${NOTIFY_TYPE_ALERT} -a "${TARGET_EMAIL}" -e;
                else
                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command ${MAILER_CLASS} -m ${SITE_MONITOR_EMAIL} -t ${NOTIFY_TYPE_ALERT} -e";

                    . ${MAILER_CLASS} -m ${SITE_MONITOR_EMAIL} -t ${NOTIFY_TYPE_ALERT} -e;
                fi
                ;;
        esac
        NOTIFY_CODE=${?};

        CNAME=$(basename ${0});
        [[ ! -z "${TRACE}" && "${TRACE}" = "${_TRUE}" ]] && set -x;
    local METHOD_NAME="${CNAME}#${0}";

        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "NOTIFY_CODE -> ${NOTIFY_CODE}";

        unset MONITOR;
    
        if [ ${NOTIFY_CODE} != 0 ]
        then
            ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "An error occurred sending the notification. Please process manually.";
    
            (( ERROR_COUNT += 1 ));
        fi
    fi

    if [ ${ERROR_COUNT} != 0 ]
    then
        RETURN_CODE=1;
    else
        RETURN_CODE=0;
    fi

    ERROR_COUNT=0;
    unset RET_CODE;
    unset TARGET_SYSTEM;
    unset MONITORING_SCRIPT;
    unset MONITORED_HOST;
    unset PROJECT_CODE;
    unset INSTANCE_NAME;
    unset EXPIRY_DATE;
    unset SITE_HOSTNAME;
    unset OWNER_DIST;
    unset CONTACT_CODE;
    unset CERT_ENTRY;
    unset NOTIFY_CODE;
    unset ENTRY;
    unset OWNER_DIST;
    unset CONTACT_CODE;
    unset PROJECT_CODE;
    unset EXPIRY_DATE;
    unset SITE_HOSTNAME;
    unset SITE_REGION;
    unset INSTANCE_NAME;
    unset INSTANCE_LIST;
    unset ENTRY;
    unset CURR_IFS;

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";
}

#===  FUNCTION  ===============================================================
#      NAME:  usage
#   DESCRIPTION:  Provide information on the usage of this application
#    PARAMETERS:  None
#   RETURNS:  0
#==============================================================================
function usage
{
    [[ ! -z "${TRACE}" && "${TRACE}" = "${_TRUE}" ]] && set -x;
    local METHOD_NAME="${CNAME}#${0}";

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";

    print "${CNAME} - Executes a selected monitoring process.";
    print " -m    -> The monitoring process to execute.";
    print " -s    -> Target server to execute against. (Optional)";
    print " -d    -> The expiration date (in unix epoch) (Optional)";
    print " -e    -> Execute the request";
    print " -h|-? -> Show this help";

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

    return 3;
}

[[ -z "${PLUGIN_ROOT_DIR}" && -s ${SCRIPT_ROOT}/../lib/${PLUGIN_NAME}.sh ]] && . ${SCRIPT_ROOT}/../lib/${PLUGIN_NAME}.sh;
[ -z "${PLUGIN_ROOT_DIR}" ] && exit 1

[ ${#} -eq 0 ] && usage;

OPTIND=0;
METHOD_NAME="${CNAME}#startup";

[[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${CNAME} starting up.. Process ID ${$}";
[[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Provided arguments: ${@}";
[[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";

while getopts ":m:s:d:a:eh:" OPTIONS
do
    case "${OPTIONS}" in
        m)
            ## set the platform
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting MONITORING_SCRIPT..";

            ## Capture the site root
            MONITORING_SCRIPT=${OPTARG};

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "MONITORING_SCRIPT -> ${MONITORING_SCRIPT}";
            ;;
        s)
            ## set the platform
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting TARGET_SYSTEM..";

            ## Capture the site root
            typeset -l TARGET_SYSTEM="${OPTARG}";

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "TARGET_SYSTEM -> ${TARGET_SYSTEM}";
            ;;
        d)
            ## set the platform
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting EXPIRY_EPOCH..";

            ## Capture the site root
            EXPIRY_EPOCH=${OPTARG};

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "EXPIRY_EPOCH -> ${EXPIRY_EPOCH}";
            ;;
        a)
            ## target email address (optional)
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting TARGET_EMAIL..";

            ## Capture the site root
            typeset -l TARGET_EMAIL="${OPTARG}";

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "TARGET_EMAIL -> ${TARGET_EMAIL}";
            ;;
        e)
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Validating request..";

            ## Make sure we have enough information to process
            ## and execute
            if [ -z "${RETURN_CODE}" ]
            then
                if [ -z "${MONITORING_SCRIPT}" ]
                then
                    ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No monitoring script was provided. Cannot continue.";
                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                    RETURN_CODE=21;
                else
                    ## We have enough information to process the request, continue
                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Request validated - executing";
                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                    executeMonitoringScript;
                fi
            fi
            ;;
        h)
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

            usage;
            ;;
        [\?])
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

            usage;
            ;;
        *)
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

            usage;
            ;;
    esac
done

shift ${OPTIND}-1;
return ${RETURN_CODE};
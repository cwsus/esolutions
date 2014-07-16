#!/usr/bin/env ksh
#==============================================================================
#
#          FILE:  runKeyGeneration.sh
#         USAGE:  ./runKeyGeneration.sh
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

[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -x;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -x;

## Application constants
CNAME="$(/usr/bin/env basename ${0})";
SCRIPT_ABSOLUTE_PATH="$(cd "${0%/*}" 2>/dev/null; /usr/bin/env echo "${PWD}"/"${0##*/}")";
SCRIPT_ROOT="$(/usr/bin/env dirname ${SCRIPT_ABSOLUTE_PATH})";
METHOD_NAME="${CNAME}#startup";

[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +x;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +x;

[ -z "${PLUGIN_ROOT_DIR}" ] && [ -f ${SCRIPT_ROOT}/../lib/plugin ] && . ${SCRIPT_ROOT}/../lib/plugin;

[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -x;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -x;

[ -z "${PLUGIN_ROOT_DIR}" ] && /usr/bin/env echo "Failed to locate configuration data. Cannot continue." && return 1;

[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -x;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -x;

[ -f ${APP_ROOT}/${LIB_DIRECTORY}/aliases ] && . ${APP_ROOT}/${LIB_DIRECTORY}/aliases;
[ -f ${APP_ROOT}/${LIB_DIRECTORY}/functions ] && . ${APP_ROOT}/${LIB_DIRECTORY}/functions;
[ -s ${PLUGIN_LIB_DIRECTORY}/aliases ] && . ${PLUGIN_LIB_DIRECTORY}/aliases;
[ -s ${PLUGIN_LIB_DIRECTORY}/functions ] && . ${PLUGIN_LIB_DIRECTORY}/functions;

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
typeset METHOD_NAME="${CNAME}#startup";

[ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";

if [ -z "${RET_CODE}" ] || [ ${RET_CODE} -ne 0 ]
then
    ${LOGGER} "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Security violation found while executing ${CNAME} by ${IUSER_AUDIT} on host ${SYSTEM_HOSTNAME}";
    ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Security configuration blocks execution. Please verify security configuration.";

    echo "Security configuration does not allow the requested action.";

    return ${RET_CODE};
fi

#===  FUNCTION  ===============================================================
#          NAME:  generateRNDCKeys
#   DESCRIPTION:  Returns a full response from DiG for a provided address
#    PARAMETERS:  None
#          NAME:  usage
#==============================================================================
function generateRNDCKeys
{
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -x;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -x;
    typeset METHOD_NAME="${CNAME}#${0}";
    typeset RETURN_CODE=0;

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Provided arguments: ${@}";

    if [[ ! -z "${IS_RNDC_MGMT_ENABLED}" && "${IS_RNDC_MGMT_ENABLED}" = "${_FALSE}" ]]
    then
        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RNDC Key management has not been enabled. Cannot continue.";

        RETURN_CODE=97;

        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RETURN_CODE -> ${RETURN_CODE}";
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

        [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +x;
        [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +x;

        return ${RETURN_CODE};
    fi

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Generating ${KEYTYPE} keyfiles..";

    GENERATION_DATE=$(date +"%m-%d-%Y");

    ## build out rndc keys. we generate two - the typeset and the remote.
    ## start with the local
    if [ ! -z "${LOCAL_EXECUTION}" ] && [ "${LOCAL_EXECUTION}" = "${_TRUE}" ]
    then
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing ${PLUGIN_LIB_DIRECTORY}/executors/execute_key_generation.sh -g ${KEYTYPE},${CHANGE_NUM},${IUSER_AUDIT} -e..";

        ${PLUGIN_LIB_DIRECTORY}/executors/executeKeyGeneration.sh -g ${KEYTYPE},${CHANGE_NUM},${IUSER_AUDIT} -e;
    else
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing ssh ${NAMED_MASTER} \"execute_key_generation.sh -g ${KEYTYPE},${CHANGE_NUM},${IUSER_AUDIT} -e\"";

        ssh ${NAMED_MASTER} "${REMOTE_APP_ROOT}/${PLUGIN_LIB_DIRECTORY}/executors/executeKeyGeneration.sh -g ${KEYTYPE},${CHANGE_NUM},${IUSER_AUDIT} -e";
    fi
    typeset -i RET_CODE=${?};

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";

    if [ -z "${RET_CODE}" ]
    then
        ## no key generated
        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "An "ERROR" occurred while generating the new keys.";

        RETURN_CODE=6;

        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RETURN_CODE -> ${RETURN_CODE}";
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

        [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +x;
        [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +x;

        return ${RETURN_CODE};
    fi

    ## clean up the files if they exist
    [ -s ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_CONF_FILE}) ] && rm -rf ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_CONF_FILE});
    [ -s ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_KEY_FILE}) ] && rm -rf ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_KEY_FILE});

    ## we only get back the remote key. build out the files
    ## this is a typeset rndc key. build the file
    ## once for the rndc conf file...
    echo "# keyfile ${RNDC_LOCAL_KEY} generated by ${IUSER_AUDIT} on ${GENERATION_DATE}\n" >> ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_CONF_FILE});
    echo "# change request number ${CHANGE_NUM}\n" >> ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_CONF_FILE});
    echo "key \"${RNDC_LOCAL_KEY}\" {\n" >> ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_CONF_FILE});
    echo "    algorithm         hmac-md5;\n" >> ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_CONF_FILE});
    echo "    secret            \"${RET_CODE}\";\n" >> ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_CONF_FILE});
    echo "};\n\n" >> ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_CONF_FILE});

    ## and then add our default server..
    echo "options {\n" >> ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_CONF_FILE});
    echo "    default-key       \"${RNDC_LOCAL_KEY}\";\n" >> ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_CONF_FILE});
    echo "    default-server    127.0.0.1;\n" >> ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_CONF_FILE});
    echo "    default-port      ${RNDC_LOCAL_PORT};\n" >> ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_CONF_FILE});
    echo "};\n\n" >> ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_CONF_FILE});

    ## and again for rndc.key
    echo "# keyfile ${RNDC_LOCAL_KEY} generated by ${IUSER_AUDIT} on ${GENERATION_DATE}\n" >> ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_KEY_FILE});
    echo "# change request number ${CHANGE_NUM}\n" >> ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_KEY_FILE});
    echo "key \"${RNDC_LOCAL_KEY}\" {\n" >> ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_KEY_FILE});
    echo "    algorithm         hmac-md5;\n" >> ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_KEY_FILE});
    echo "    secret            \"${RET_CODE}\";\n" >> ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_KEY_FILE});
    echo "};\n\n" >> ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_KEY_FILE});

    ## unset the key
    unset RET_CODE;

    if [ -s ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_CONF_FILE}) ] \
        && [ -s ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_KEY_FILE}) ]
    then
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${RNDC_LOCAL_KEY} generation complete. Beginning key transfers..";

        ## now we need to transfer the files out to the slaves
        A=0;

        ## determine if we have a secondary master. if we
        ## do, then this process changes slightly.. first,
        ## we need to get the primary master's rndc conf/key
        ## files, and send them to the secondary master
        if [ ! -z "${AVAILABLE_MASTER_SERVERS}" ]
        then
            for AVAILABLE_MASTER in ${AVAILABLE_MASTER_SERVERS}
            do
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Now operating on ${AVAILABLE_MASTER} .. ";

                ## we have an available master. get keys and copy to it.
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command ${PLUGIN_LIB_DIRECTORY}/tcl/runSCPConnection.exp remote-copy ${AVAILABLE_MASTER_SERVERS} ${NAMED_ROOT}/${RNDC_KEY_FILE} ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_KEY_FILE}).MASTER";

                ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSCPConnection.exp remote-copy ${AVAILABLE_MASTER_SERVERS} ${NAMED_ROOT}/${RNDC_KEY_FILE} ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_KEY_FILE}).MASTER ${SSH_USER_NAME} ${SSH_USER_AUTH};

                ## make sure we got it
                if [ -s ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_KEY_FILE}).MASTER ]
                then
                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSCPConnection.exp remote-copy ${AVAILABLE_MASTER_SERVERS} ${NAMED_ROOT}/${RNDC_KEY_FILE} ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_CONF_FILE}).MASTER";

                    ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSCPConnection.exp remote-copy ${AVAILABLE_MASTER_SERVERS} ${NAMED_ROOT}/${RNDC_CONF_FILE} ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_CONF_FILE}).MASTER ${SSH_USER_NAME} ${SSH_USER_AUTH};

                    ## make sure we got it
                    if [ -s ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${RNDC_CONF_FILE}).MASTER ]
                    then
                        ## ok, we have our files. now we need to place them
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Files received. Placing..";

                        for KEYFILE in $(cut -d "/" -f 3 <<< ${RNDC_KEY_FILE}) $(cut -d "/" -f 3 <<< ${RNDC_CONF_FILE})
                        do
                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Transferring ${KEYFILE}..";

                            ## get our checksum
                            OP_FILE_CKSUM=$(cksum ${PLUGIN_WORK_DIRECTORY}/${KEYFILE} | awk '{print $1}');

                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OP_FILE_CKSUM -> ${OP_FILE_CKSUM}";
                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSCPConnection.exp local-copy ${AVAILABLE_MASTER} ${PLUGIN_WORK_DIRECTORY}/${KEYFILE} ${NAMED_ROOT}/etc/dnssec-keys/${KEYFILE}";

                            ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSCPConnection.exp local-copy ${AVAILABLE_MASTER} ${PLUGIN_WORK_DIRECTORY}/${KEYFILE} ${NAMED_ROOT}/etc/dnssec-keys/${KEYFILE} ${SSH_USER_NAME} ${SSH_USER_AUTH};

                            ## file copied. validate -
                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "File copied. Validating..";
                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command ssh ${AVAILABLE_MASTER} \"cksum ${NAMED_ROOT}/etc/dnssec-keys/${KEYFILE}\"";

                            ssh ${AVAILABLE_MASTER} "cksum ${NAMED_ROOT}/etc/dnssec-keys/${KEYFILE} | awk '{print $1}'";

                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "DST_FILE_CKSUM -> ${DST_FILE_CKSUM}";

                            if [ ! -z "${DST_FILE_CKSUM}" ]
                            then
                                ## got our remote checksum
                                if [ "${OP_FILE_CKSUM}" = "${DST_FILE_CKSUM}" ]
                                then
                                    ## successful execution. continue.
                                    continue;
                                else
                                    ## checksum mismatch.
                                    ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CHECKSUM MISMATCH: Local checksum - ${OP_FILE_CKSUM}, Remote checksum - ${DST_FILE_CKSUM}";

                                    RETURN_CODE=90;
                                    break;
                                fi
                            else
                                ## didn't get back a cksum. maybe the file doesnt exist ?
                                ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Remote checksum generation failed. Cannot continue.";

                                RETURN_CODE=90;
                                break;
                            fi

                            ## unset checksums
                            unset OP_FILE_CKSUM;
                            unset DST_FILE_CKSUM;
                        done

                        if [ -z "${RETURN_CODE}" ]
                        then
                            ## call out restart_dns.sh - SysV init {reload} to apply the changes
                            if [ ! -z "${LOCAL_EXECUTION}" ] && [ "${LOCAL_EXECUTION}" = "${_TRUE}" ]
                            then
                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Local execution is set to TRUE.";

                                ## no trace here, this is a bourne shell script
                                . ${PLUGIN_LIB_DIRECTORY}/executors/executeControlRequest.sh -c restart -r -e;
                            else
                                ## MUST execute as root - sudo is best possible option.
                                ## this is NOT required if you are configured to ssh as root.
                                ssh ${AVAILABLE_MASTER} "${REMOTE_APP_ROOT}/${PLUGIN_LIB_DIRECTORY}/executors/executeControlRequest.sh -c restart -r -e";
                            fi

                            RESTART_CODE=${?};

                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RESTART_CODE -> ${RESTART_CODE}";

                            if [ ${RESTART_CODE} -ne 0 ]
                            then
                                ${LOGGER} "WARN" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "named service on ${AVAILABLE_MASTER} failed to restart.";

                                echo "WARNING: named service on ${AVAILABLE_MASTER} failed to restart.";

                                sleep "${MESSAGE_DELAY}";
                            fi
                        fi

                        ## unset keyfile
                        unset KEYFILE;
                    else
                        ## key generation succeeded, but we failed to write the file
                        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to write out temporary key configuration. Cannot continue.";

                        RETURN_CODE=47;
                    fi
                else
                    ## key generation succeeded, but we failed to write the file
                    ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to write out temporary key configuration. Cannot continue.";

                    RETURN_CODE=47;
                fi
            done

            unset AVAILABLE_MASTERS;
        else
            if [ -z "${AVAILABLE_MASTERS}" ]
            then
                while [ ${A} -ne ${#DNS_SLAVES[@]} ]
                do
                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Now operating on ${DNS_SLAVES[${A}]} .. ";

                    for KEYFILE in $(cut -d "/" -f 3 <<< ${RNDC_KEY_FILE}) $(cut -d "/" -f 3 <<< ${RNDC_CONF_FILE})
                    do
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Transferring ${KEYFILE}..";

                        ## get our checksum
                        OP_FILE_CKSUM=$(cksum ${PLUGIN_WORK_DIRECTORY}/${KEYFILE} | awk '{print $1}');

                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OP_FILE_CKSUM -> ${OP_FILE_CKSUM}";
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSCPConnection.exp local-copy ${DNS_SLAVES[${A}]} ${PLUGIN_WORK_DIRECTORY}/${KEYFILE} ${NAMED_ROOT}/etc/dnssec-keys/${KEYFILE}";

                        ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSCPConnection.exp local-copy ${DNS_SLAVES[${A}]} ${PLUGIN_WORK_DIRECTORY}/${KEYFILE} ${NAMED_ROOT}/etc/dnssec-keys/${KEYFILE} ${SSH_USER_NAME} ${SSH_USER_AUTH};

                        ## file copied. validate -
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "File copied. Validating..";
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command ssh ${DNS_SLAVES[${A}]} \"cksum ${NAMED_ROOT}/etc/dnssec-keys/${KEYFILE}\"";

                        DST_FILE_CKSUM=$(ssh ${DNS_SLAVES[${A}]} "cksum ${NAMED_ROOT}/etc/dnssec-keys/${KEYFILE}" | awk '{print $1}');

                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "DST_FILE_CKSUM -> ${DST_FILE_CKSUM}";

                        if [ ! -z "${DST_FILE_CKSUM}" ]
                        then
                            ## got our remote checksum
                            if [ "${OP_FILE_CKSUM}" = "${DST_FILE_CKSUM}" ]
                            then
                                ## successful execution. continue.
                                continue;
                            else
                                ## checksum mismatch.
                                ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CHECKSUM MISMATCH: Local checksum - ${OP_FILE_CKSUM}, Remote checksum - ${DST_FILE_CKSUM}";

                                RETURN_CODE=90;
                                break;
                            fi
                        else
                            ## didn't get back a cksum. maybe the file doesnt exist ?
                            ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Remote checksum generation failed. Cannot continue.";

                            RETURN_CODE=90;
                            break;
                        fi

                        ## unset checksums
                        unset OP_FILE_CKSUM;
                        unset DST_FILE_CKSUM;
                    done

                    if [ -z "${RETURN_CODE}" ]
                    then
                        ## call out restart_dns.sh - SysV init {reload} to apply the changes
                        if [ ! -z "${LOCAL_EXECUTION}" ] && [ "${LOCAL_EXECUTION}" = "${_TRUE}" ]
                        then
                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Local execution is set to TRUE.";

                            ## no trace here, this is a bourne shell script
                            . ${PLUGIN_LIB_DIRECTORY}/executors/executeControlRequest.sh -c restart -r -e;
                        else
                            ## MUST execute as root - sudo is best possible option.
                            ## this is NOT required if you are configured to ssh as root.
                            ssh ${DNS_SLAVES[${A}]} "${REMOTE_APP_ROOT}/${PLUGIN_LIB_DIRECTORY}/executors/executeControlRequest.sh -c restart -r -e";
                        fi

                        RESTART_CODE=${?};

                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RESTART_CODE -> ${RESTART_CODE}";

                        if [ ${RESTART_CODE} -ne 0 ]
                        then
                            ${LOGGER} "WARN" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "named service on ${DNS_SLAVES[${A}]} failed to restart.";

                            echo "WARNING: named service on ${DNS_SLAVES[${A}]} failed to restart.";

                            sleep "${MESSAGE_DELAY}";
                        fi
                    fi

                    (( A += 1 ));
                done
            else
                while [ ${A} -ne ${#EXT_SLAVES[@]} ]
                do
                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Now operating on ${EXT_SLAVES[${A}]} .. ";

                    for KEYFILE in $(cut -d "/" -f 3 <<< ${RNDC_KEY_FILE}) $(cut -d "/" -f 3 <<< ${RNDC_CONF_FILE})
                    do
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Transferring ${KEYFILE}..";

                        ## get our checksum
                        OP_FILE_CKSUM=$(cksum ${PLUGIN_WORK_DIRECTORY}/${KEYFILE} | awk '{print $1}');

                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OP_FILE_CKSUM -> ${OP_FILE_CKSUM}";
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSCPConnection.exp local-copy ${EXT_SLAVES[${A}]} ${PLUGIN_WORK_DIRECTORY}/${KEYFILE} ${NAMED_ROOT}/etc/dnssec-keys/${KEYFILE}";

                        ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSCPConnection.exp local-copy ${EXT_SLAVES[${A}]} ${PLUGIN_WORK_DIRECTORY}/${KEYFILE} ${NAMED_ROOT}/etc/dnssec-keys/${KEYFILE} ${SSH_USER_NAME} ${SSH_USER_AUTH};

                        ## file copied. validate -
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "File copied. Validating..";
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command ssh ${EXT_SLAVES[${A}]} \"cksum ${NAMED_ROOT}/etc/dnssec-keys/${KEYFILE}\"";

                        DST_FILE_CKSUM=$(ssh ${EXT_SLAVES[${A}]} "cksum ${NAMED_ROOT}/etc/dnssec-keys/${KEYFILE}" | awk '{print $1}');

                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "DST_FILE_CKSUM -> ${DST_FILE_CKSUM}";

                        if [ ! -z "${DST_FILE_CKSUM}" ]
                        then
                            ## got our remote checksum
                            if [ "${OP_FILE_CKSUM}" = "${DST_FILE_CKSUM}" ]
                            then
                                ## successful execution. continue.
                                continue;
                            else
                                ## checksum mismatch.
                                ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CHECKSUM MISMATCH: Local checksum - ${OP_FILE_CKSUM}, Remote checksum - ${DST_FILE_CKSUM}";

                                RETURN_CODE=90;
                                break;
                            fi
                        else
                            ## didn't get back a cksum. maybe the file doesnt exist ?
                            ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Remote checksum generation failed. Cannot continue.";

                            RETURN_CODE=90;
                            break;
                        fi

                        ## unset checksums
                        unset OP_FILE_CKSUM;
                        unset DST_FILE_CKSUM;
                    done

                    if [ -z "${RETURN_CODE}" ]
                    then
                        ## call out restart_dns.sh - SysV init {reload} to apply the changes
                        if [ ! -z "${LOCAL_EXECUTION}" ] && [ "${LOCAL_EXECUTION}" = "${_TRUE}" ]
                        then
                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Local execution is set to TRUE.";

                            ## no trace here, this is a bourne shell script
                            ${PLUGIN_LIB_DIRECTORY}/executors/executeControlRequest.sh -c restart -r -e;
                        else
                            ## MUST execute as root - sudo is best possible option.
                            ## this is NOT required if you are configured to ssh as root.
                            ssh ${EXT_SLAVES[${A}]} "${REMOTE_APP_ROOT}/${PLUGIN_LIB_DIRECTORY}/executors/executeControlRequest.sh -c restart -r -e";
                        fi
                        RESTART_CODE=${?};

                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RESTART_CODE -> ${RESTART_CODE}";

                        if [ ${RESTART_CODE} -ne 0 ]
                        then
                            ${LOGGER} "WARN" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "named service on ${EXT_SLAVES[${A}]} failed to restart.";

                            echo "WARNING: named service on ${EXT_SLAVES[${A}]} failed to restart.";

                            sleep "${MESSAGE_DELAY}";
                        fi
                    fi

                    (( A += 1 ));
                done
            fi
        fi

        if [ -z "${RETURN_CODE}" ]
        then
            ## our slave servers as well as our master have the new keyfiles.
            ## slaves have been restarted, but master has not. lets do that now.
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Restarting named on ${NAMED_MASTER}..";

            ## call out restart_dns.sh - SysV init {reload} to apply the changes
            if [ ! -z "${LOCAL_EXECUTION}" ] && [ "${LOCAL_EXECUTION}" = "${_TRUE}" ]
            then
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Local execution is set to TRUE.";

                ## no trace here, this is a bourne shell script
                ${PLUGIN_LIB_DIRECTORY}/executors/executeControlRequest.sh -c restart -r -e;
            else
                ## MUST execute as root - sudo is best possible option.
                ## this is NOT required if you are configured to ssh as root.
                ssh ${NAMED_MASTER} "${REMOTE_APP_ROOT}/${PLUGIN_LIB_DIRECTORY}/executors/executeControlRequest.sh -c restart -r -e";
            fi
            RESTART_CODE=${?};

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RESTART_CODE -> ${RESTART_CODE}";

            if [ ${RESTART_CODE} -ne 0 ]
            then
                ${LOGGER} "WARN" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "named service on ${NAMED_MASTER} failed to restart.";

                echo "WARNING: named service on ${NAMED_MASTER} failed to restart.";

                sleep "${MESSAGE_DELAY}";
            fi
        else
            ## most execution steps completed. restarts failed. user should already be notified,
            ## so lets just continue on our merry way.
            ## unset some things
            A=0;
            unset OP_FILE_CKSUM;
            unset DST_FILE_CKSUM;

            RETURN_CODE=0;
        fi
    else
        ## key generation succeeded, but we failed to write the file
        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to write out temporary key configuration. Cannot continue.";

        RETURN_CODE=47;
    fi

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";


    return ${RETURN_CODE};
}

#===  FUNCTION  ===============================================================
#          NAME:  generateTSIGKeys
#   DESCRIPTION:  Returns a full response from DiG for a provided address
#    PARAMETERS:  None
#          NAME:  usage
#==============================================================================
function generateTSIGKeys
{
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -x;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -x;
    typeset METHOD_NAME="${CNAME}#${0}";
    typeset RETURN_CODE=0;

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Provided arguments: ${@}";

    if [[ ! -z "${IS_TSIG_MGMT_ENABLED}" && "${IS_TSIG_MGMT_ENABLED}" = "${_FALSE}" ]]
    then
        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "TSIG Key management has not been enabled. Cannot continue.";

        RETURN_CODE=97;

        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RETURN_CODE -> ${RETURN_CODE}";
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

        [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +x;
        [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +x;

        return ${RETURN_CODE};
    fi

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Generating TSIG keyfiles..";

    GENERATION_DATE=$(date +"%m-%d-%Y");

    ## build out rndc keys. we generate two - the typeset and the remote.
    ## start with the local
    if [ ! -z "${LOCAL_EXECUTION}" ] && [ "${LOCAL_EXECUTION}" = "${_TRUE}" ]
    then
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing ${PLUGIN_LIB_DIRECTORY}/executors/execute_key_generation.sh -g ${KEYTYPE},${CHANGE_NUM},${IUSER_AUDIT} -e..";

        RET_CODE=$(${PLUGIN_LIB_DIRECTORY}/executors/executeKeyGeneration.sh -g ${KEYTYPE},${CHANGE_NUM},${IUSER_AUDIT} -e);
    else
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing ssh ${NAMED_MASTER} \"execute_key_generation.sh -g ${KEYTYPE},${CHANGE_NUM},${IUSER_AUDIT} -e\"";

        RET_CODE=$(ssh ${NAMED_MASTER} "${REMOTE_APP_ROOT}/${PLUGIN_LIB_DIRECTORY}/executors/executeKeyGeneration.sh -g ${KEYTYPE},${CHANGE_NUM},${IUSER_AUDIT} -e");
    fi

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";

    if [ -z "${RET_CODE}" ]
    then
        ## no key generated
        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "An "ERROR" occurred while generating the new keys.";

        return 6;
    fi

    ## clean up the files if they exist
    [ -s ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${TRANSFER_KEY_FILE}) ] && rm -rf ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${TRANSFER_KEY_FILE});
    [ -s ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${TRANSFER_KEY_FILE}) ] && rm -rf ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${TRANSFER_KEY_FILE});

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Generating TSIG keyfiles..";

    ## we get back the key, but its for the slave servers.
    ## write it out
    ## this is a typeset rndc key. build the file
    echo "# keyfile ${TSIG_TRANSFER_KEY} generated by ${IUSER_AUDIT} on ${GENERATION_DATE}\n" >> ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${TRANSFER_KEY_FILE});
    echo "# change request number ${CHANGE_NUM}\n" >> ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${TRANSFER_KEY_FILE});
    echo "key \"${TSIG_TRANSFER_KEY}\" {\n" >> ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${TRANSFER_KEY_FILE});
    echo "    algorithm    hmac-md5;\n" >> ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${TRANSFER_KEY_FILE});
    echo "    secret       \"${RET_CODE}\";\n" >> ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${TRANSFER_KEY_FILE});
    echo "};\n\n" >> ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${TRANSFER_KEY_FILE});

    ## and then write out our master nameserver clauses
    echo "server ${NAMED_MASTER_ADDRESS} {\n" >> ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${TRANSFER_KEY_FILE});
    echo "    keys { ${TSIG_TRANSFER_KEY}; };\n" >> ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${TRANSFER_KEY_FILE});
    echo "};\n\n" >> ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${TRANSFER_KEY_FILE});

    if [ -s ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${TRANSFER_KEY_FILE}) ]
    then
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${TSIG_TRANSFER_KEY} generation complete.";

        ## now we need to transfer the files out to the slaves
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Beginning key transfers..";

        A=0;

        while [ ${A} -ne ${#DNS_SLAVES[@]} ]
        do
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Now operating on ${DNS_SLAVES[${A}]} .. ";

            ## get our checksum
            OP_FILE_CKSUM=$(cksum ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${TRANSFER_KEY_FILE}) | awk '{print $1}');

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OP_FILE_CKSUM -> ${OP_FILE_CKSUM}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSCPConnection.exp local-copy ${DNS_SLAVES[${A}]} ${PLUGIN_WORK_DIRECTORY}/$(cut -d \"/\" -f 3 <<< ${TRANSFER_KEY_FILE}) ${NAMED_ROOT}/${TRANSFER_KEY_FILE}";

            THIS_CNAME="${CNAME}";
            unset METHOD_NAME;
            unset CNAME;

            [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +x;
            [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +x;

            ## validate the input
            ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSCPConnection.exp local-copy ${DNS_SLAVES[${A}]} ${PLUGIN_WORK_DIRECTORY}/$(cut -d "/" -f 3 <<< ${TRANSFER_KEY_FILE}) ${NAMED_ROOT}/${TRANSFER_KEY_FILE} ${SSH_USER_NAME} ${SSH_USER_AUTH};
            typeset -i RET_CODE=${?};

            [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -x;
            [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -x;

            CNAME="${THIS_CNAME}";
            typeset METHOD_NAME="${THIS_CNAME}#${0}";

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";

            ## file copied. validate -
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "File copied. Validating..";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command ssh ${DNS_SLAVES[${A}]} \"cksum ${NAMED_ROOT}/${TRANSFER_KEY_FILE} | awk '{print $1}'\"";

            DST_FILE_CKSUM=$(ssh ${NAMED_MASTER} "cksum ${NAMED_ROOT}/${TRANSFER_KEY_FILE} | awk '{print $1}'");

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "DST_FILE_CKSUM -> ${DST_FILE_CKSUM}";

            if [ ! -z "${DST_FILE_CKSUM}" ]
            then
                ## got our remote checksum
                if [ "${OP_FILE_CKSUM}" = "${DST_FILE_CKSUM}" ]
                then
                    ## successful execution. continue
                    continue;
                else
                    ## checksum mismatch.
                    ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CHECKSUM MISMATCH: Local checksum - ${OP_FILE_CKSUM}, Remote checksum - ${DST_FILE_CKSUM}";

                    RETURN_CODE=90;
                    break;
                fi
            else
                ## didn't get back a cksum. maybe the file doesnt exist ?
                ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Remote checksum generation failed. Cannot continue.";

                RETURN_CODE=90;
                break;
            fi

            if [ -z "${RETURN_CODE}" ]
            then
                ## successful execution. bounce the node.
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Restarting named on ${DNS_SLAVES[${A}]}..";

                ## call out restart_dns.sh - SysV init {reload} to apply the changes
                if [ ! -z "${LOCAL_EXECUTION}" ] && [ "${LOCAL_EXECUTION}" = "${_TRUE}" ]
                then
                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Local execution is set to TRUE.";

                    ## no trace here, this is a bourne shell script
                        unset METHOD_NAME;
                    unset CNAME;

                    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +x;
                    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +x;

                    ## validate the input
                    ${PLUGIN_LIB_DIRECTORY}/executors/executeControlRequest.sh -c restart -e;
                    typeset -i RET_CODE=${?};

                    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -x;
                    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -x;

                    CNAME="${THIS_CNAME}";
                    typeset METHOD_NAME="${THIS_CNAME}#${0}";

                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";
                else
                    ## MUST execute as root - sudo is best possible option.
                    ## this is NOT required if you are configured to ssh as root.
                        unset METHOD_NAME;
                    unset CNAME;

                    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +x;
                    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +x;

                    ## validate the input
                    ssh ${DNS_SLAVES[${A}]} "${REMOTE_APP_ROOT}/${PLUGIN_LIB_DIRECTORY}/executors/executeControlRequest.sh -c restart -e";
                    typeset -i RET_CODE=${?};

                    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -x;
                    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -x;

                    CNAME="${THIS_CNAME}";
                    typeset METHOD_NAME="${THIS_CNAME}#${0}";

                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";
                fi

                RESTART_CODE=${?};

                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RESTART_CODE -> ${RESTART_CODE}";

                if [ ${RESTART_CODE} -ne 0 ]
                then
                    ${LOGGER} "WARN" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "named service on ${DNS_SLAVES[${A}]} failed to restart.";

                    echo "WARNING: named service on ${DNS_SLAVES[${A}]} failed to restart.";

                    sleep "${MESSAGE_DELAY}";
                fi

                unset RESTART_CODE;
            fi

            (( A += 1 ));
        done

        if [ -z "${RETURN_CODE}" ]
        then
            ## our slave servers as well as our master have the new keyfiles.
            ## slaves have been restarted, but master has not. lets do that now.
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Restarting named on ${NAMED_MASTER}..";

            ## call out restart_dns.sh - SysV init {reload} to apply the changes
            if [ ! -z "${LOCAL_EXECUTION}" ] && [ "${LOCAL_EXECUTION}" = "${_TRUE}" ]
            then
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Local execution is set to TRUE.";

                ## no trace here, this is a bourne shell script
                unset METHOD_NAME;
                unset CNAME;

                [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +x;
                [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +x;

                ## validate the input
                ${PLUGIN_LIB_DIRECTORY}/executors/executeControlRequest.sh -c restart -e;
                typeset -i RET_CODE=${?};

                [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -x;
                [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -x;

                CNAME="${THIS_CNAME}";
                typeset METHOD_NAME="${THIS_CNAME}#${0}";

                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";
            else
                ## MUST execute as root - sudo is best possible option.
                ## this is NOT required if you are configured to ssh as root.
                unset METHOD_NAME;
                unset CNAME;

                [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +x;
                [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +x;

                ## validate the input
                ssh ${NAMED_MASTER} "${REMOTE_APP_ROOT}/${PLUGIN_LIB_DIRECTORY}/executors/executeControlRequest.sh -c restart -e";
                typeset -i RET_CODE=${?};

                [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -x;
                [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -x;

                CNAME="${THIS_CNAME}";
                typeset METHOD_NAME="${THIS_CNAME}#${0}";

                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";
            fi

            RESTART_CODE=${?};

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RESTART_CODE -> ${RESTART_CODE}";

            if [ ${RESTART_CODE} -ne 0 ]
            then
                ${LOGGER} "WARN" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "named service on ${NAMED_MASTER} failed to restart.";

                echo "WARNING: named service on ${DNS_SLAVES[${A}]} failed to restart.";

                sleep "${MESSAGE_DELAY}";
            fi
        else
            ## most execution steps completed. restarts failed. user should already be notified,
            ## so lets just continue on our merry way.
            ## unset some things
            A=0;
            unset OP_FILE_CKSUM;
            unset DST_FILE_CKSUM;
        fi
    else
        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to write out temporary key configuration. Cannot continue.";

        RETURN_CODE=47;

        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RETURN_CODE -> ${RETURN_CODE}";
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

        [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +x;
        [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +x;

        return ${RETURN_CODE};
    fi

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";


    return ${RETURN_CODE};
}

#===  FUNCTION  ===============================================================
#          NAME:  generateDNSSECKeys
#   DESCRIPTION:  Returns a full response from DiG for a provided address
#    PARAMETERS:  None
#          NAME:  usage
#==============================================================================
function generateDNSSECKeys
{
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -x;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -x;
    typeset METHOD_NAME="${CNAME}#${0}";
    typeset RETURN_CODE=0;

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Provided arguments: ${@}";

    if [[ ! -z "${IS_DNSSEC_MGMT_ENABLED}" && "${IS_DNSSEC_MGMT_ENABLED}" = "${_FALSE}" ]]
    then
        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "TSIG Key management has not been enabled. Cannot continue.";

        RETURN_CODE=97;

        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RETURN_CODE -> ${RETURN_CODE}";
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

        [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +x;
        [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +x;

        return ${RETURN_CODE};
    fi

    ## TODO
    RETURN_CODE=1;

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RETURN_CODE -> ${RETURN_CODE}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +x;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +x;

    return ${RETURN_CODE};
}

#===  FUNCTION  ===============================================================
#          NAME:  generateDHCPDKeys
#   DESCRIPTION:  Returns a full response from DiG for a provided address
#    PARAMETERS:  None
#          NAME:  usage
#==============================================================================
function generateDHCPDKeys
{
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -x;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -x;
    typeset METHOD_NAME="${CNAME}#${0}";
    typeset RETURN_CODE=0;

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Provided arguments: ${@}";

    if [[ ! -z "${IS_DNSSEC_MGMT_ENABLED}" && "${IS_DNSSEC_MGMT_ENABLED}" = "${_FALSE}" ]]
    then
        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "TSIG Key management has not been enabled. Cannot continue.";

        RETURN_CODE=97;

        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RETURN_CODE -> ${RETURN_CODE}";
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

        [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +x;
        [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +x;

        return ${RETURN_CODE};
    fi

    ## TODO
    RETURN_CODE=1;

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RETURN_CODE -> ${RETURN_CODE}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +x;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +x;

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
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -x;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -x;
    typeset METHOD_NAME="${CNAME}#${0}";
    typeset RETURN_CODE=3;

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Provided arguments: ${@}";

    echo "${THIS_CNAME} - Performs a DNS query against the nameserver specified.\n";
    echo "Usage: ${THIS_CNAME} [ -r ] [ -d ] [ -D ] [ -t ] [ -c <change number> ] [ -e ] [ -h|-? ]
    -r         -> Generate new RNDC keys.
    -d         -> Generate new DNSSEC keys.
    -D         -> Generate new DHCPD keys.
    -t         -> Generate new TSIG keys.
    -c         -> Generate new DNSSEC keys.
    -e         -> Execute the request
    -h|-?      -> Show this help\n";

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RETURN_CODE -> ${RETURN_CODE}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +x;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +x;

    return ${RETURN_CODE};
}

[ ${#} -eq 0 ] && usage && RETURN_CODE=${?};

while getopts ":rdDtc:eh:" OPTIONS 2>/dev/null
do
    case "${OPTIONS}" in
        r)
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting GENERATE_RNDC_KEYS..";

            GENERATE_RNDC_KEYS=${_TRUE};

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "GENERATE_RNDC_KEYS -> ${GENERATE_RNDC_KEYS}";
            ;;
        d)
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting GENERATE_DNSSEC_KEYS..";

            GENERATE_DNSSEC_KEYS=${_TRUE};

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "GENERATE_DNSSEC_KEYS -> ${GENERATE_DNSSEC_KEYS}";
            ;;
        d)
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting GENERATE_DHCPD_KEYS..";

            GENERATE_DHCPD_KEYS=${_TRUE};

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "GENERATE_DHCPD_KEYS -> ${GENERATE_DHCPD_KEYS}";
            ;;
        t)
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting GENERATE_TSIG_KEYS..";

            GENERATE_TSIG_KEYS=${_TRUE};

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "GENERATE_TSIG_KEYS -> ${GENERATE_TSIG_KEYS}";
            ;;
        c)
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting CHANGE_NUM..";

            typeset -u CHANGE_NUM=${OPTARG};

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CHANGE_NUM -> ${CHANGE_NUM}";
            ;;
        e)
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Validating request..";

            if [[ -z "${GENERATE_RNDC_KEYS}" || -z "${GENERATE_DNSSEC_KEYS}" || -z "${GENERATE_TSIG_KEYS}" || -z "${GENERATE_DHCPD_KEYS}" ]]
            then
                ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No valid key generation type was provided. Unable to continue processing.";

                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                RETURN_CODE=19;

                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RETURN_CODE -> ${RETURN_CODE}";
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +x;
                [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +x;

                return ${RETURN_CODE};
            fi

            if [ -z "${CHANGE_NUM}" ]
            then
                ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No valid change request was provided. Unable to continue processing.";

                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                RETURN_CODE=19;

                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RETURN_CODE -> ${RETURN_CODE}";
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +x;
                [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +x;

                return ${RETURN_CODE};
            fi

            ## We have enough information to process the request, continue
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Request validated - executing";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

            [ "${GENERATE_RNDC_KEYS}" = "${_TRUE}" ] && generateRNDCKeys && RETURN_CODE=${?};
            [ "${GENERATE_DNSSEC_KEYS}" = "${_TRUE}" ] && generateDNSSECKeys && RETURN_CODE=${?};
            [ "${GENERATE_TSIG_KEYS}" = "${_TRUE}" ] && generateTSIGKeys && RETURN_CODE=${?};
            [ "${GENERATE_DHCPD_KEYS}" = "${_TRUE}" ] && generateDHCPDKeys && RETURN_CODE=${?};
            ;;
        *)
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

            usage && RETURN_CODE=${?};
            ;;
    esac
done

[ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RETURN_CODE -> ${RETURN_CODE}";
[ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${CNAME} -> exit";

unset SCRIPT_ABSOLUTE_PATH;
unset SCRIPT_ROOT;
unset RET_CODE;
unset CNAME;
unset METHOD_NAME;

[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +x;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +x;

[ -z "${RETURN_CODE}" ] && return 1 || return "${RETURN_CODE}";

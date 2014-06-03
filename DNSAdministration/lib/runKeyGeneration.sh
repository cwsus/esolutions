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
#          NAME:  generateRNDCKeys
#   DESCRIPTION:  Returns a full response from DiG for a provided address
#    PARAMETERS:  None
#          NAME:  usage
#==============================================================================
function generateRNDCKeys
{
    [[ ! -z "${TRACE}" && "${TRACE}" = "${_TRUE}" ]] && set -x;
    local METHOD_NAME="${CNAME}#${0}";

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";
    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Provided arguments: ${@}";

    if [[ ! -z "${IS_RNDC_MGMT_ENABLED}" && "${IS_RNDC_MGMT_ENABLED}" = "${_FALSE}" ]]
    then
        $(${LOGGER} "ERROR" ${METHOD_NAME} ${CNAME} ${LINENO} "RNDC Key management has not been enabled. Cannot continue.");

        return 97;
    fi

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Generating ${KEYTYPE} keyfiles..";

    GENERATION_DATE=$(date +"%m-%d-%Y");

    ## build out rndc keys. we generate two - the local and the remote.
    ## start with the local
    if [[ ! -z "${LOCAL_EXECUTION}" && "${LOCAL_EXECUTION}" = "${_TRUE}" ]]
    then
        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing ${PLUGIN_ROOT_DIR}/${LIB_DIRECTORY}/executors/execute_key_generation.sh -g ${KEYTYPE},${CHANGE_NUM},${IUSER_AUDIT} -e..";

        RET_CODE=$(${PLUGIN_ROOT_DIR}/${LIB_DIRECTORY}/executors/executeKeyGeneration.sh -g ${KEYTYPE},${CHANGE_NUM},${IUSER_AUDIT} -e);
    else
        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSSHConnection.exp ${NAMED_MASTER} \"${REMOTE_APP_ROOT}/${LIB_DIRECTORY}/executors/execute_key_generation.sh -g ${KEYTYPE},${CHANGE_NUM},${IUSER_AUDIT} -e\"";

        RET_CODE=$(${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSSHConnection.exp ${NAMED_MASTER} "${REMOTE_APP_ROOT}/${LIB_DIRECTORY}/executors/executeKeyGeneration.sh -g ${KEYTYPE},${CHANGE_NUM},${IUSER_AUDIT} -e");
    fi

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";

    if [ -z "${RET_CODE}" ]
    then
        ## no key generated
        $(${LOGGER} "ERROR" ${METHOD_NAME} ${CNAME} ${LINENO} "An error occurred while generating the new keys.");

        return 6;
    fi

    ## clean up the files if they exist
    [ -s ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_CONF_FILE} | cut -d "/" -f 3) ] && rm -rf ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_CONF_FILE} | cut -d "/" -f 3);
    [ -s ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_KEY_FILE} | cut -d "/" -f 3) ] && rm -rf ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_KEY_FILE} | cut -d "/" -f 3);

    ## we only get back the remote key. build out the files
    ## this is a local rndc key. build the file
    ## once for the rndc conf file...
    printf "# keyfile ${RNDC_LOCAL_KEY} generated by ${IUSER_AUDIT} on ${GENERATION_DATE}\n" >> ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_CONF_FILE} | cut -d "/" -f 3);
    printf "# change request number ${CHANGE_NUM}\n" >> ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_CONF_FILE} | cut -d "/" -f 3);
    printf "key \"${RNDC_LOCAL_KEY}\" {\n" >> ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_CONF_FILE} | cut -d "/" -f 3);
    printf "    algorithm         hmac-md5;\n" >> ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_CONF_FILE} | cut -d "/" -f 3);
    printf "    secret            \"${RET_CODE}\";\n" >> ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_CONF_FILE} | cut -d "/" -f 3);
    printf "};\n\n" >> ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_CONF_FILE} | cut -d "/" -f 3);

    ## and then add our default server..
    printf "options {\n" >> ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_CONF_FILE} | cut -d "/" -f 3);
    printf "    default-key       \"${RNDC_LOCAL_KEY}\";\n" >> ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_CONF_FILE} | cut -d "/" -f 3);
    printf "    default-server    127.0.0.1;\n" >> ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_CONF_FILE} | cut -d "/" -f 3);
    printf "    default-port      ${RNDC_LOCAL_PORT};\n" >> ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_CONF_FILE} | cut -d "/" -f 3);
    printf "};\n\n" >> ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_CONF_FILE} | cut -d "/" -f 3);

    ## and again for rndc.key
    printf "# keyfile ${RNDC_LOCAL_KEY} generated by ${IUSER_AUDIT} on ${GENERATION_DATE}\n" >> ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_KEY_FILE} | cut -d "/" -f 3);
    printf "# change request number ${CHANGE_NUM}\n" >> ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_KEY_FILE} | cut -d "/" -f 3);
    printf "key \"${RNDC_LOCAL_KEY}\" {\n" >> ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_KEY_FILE} | cut -d "/" -f 3);
    printf "    algorithm         hmac-md5;\n" >> ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_KEY_FILE} | cut -d "/" -f 3);
    printf "    secret            \"${RET_CODE}\";\n" >> ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_KEY_FILE} | cut -d "/" -f 3);
    printf "};\n\n" >> ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_KEY_FILE} | cut -d "/" -f 3);

    ## unset the key
    unset RET_CODE;

    if [ -s ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_CONF_FILE} | cut -d "/" -f 3) ] \
        && [ -s ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_KEY_FILE} | cut -d "/" -f 3) ]
    then
        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${RNDC_LOCAL_KEY} generation complete. Beginning key transfers..";

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
                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Now operating on ${AVAILABLE_MASTER} .. ";

                ## we have an available master. get keys and copy to it.
                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command ${PLUGIN_ROOT_DIR}/${LIB_DIRECTORY}/tcl/runSCPConnection.exp remote-copy ${AVAILABLE_MASTER_SERVERS} ${NAMED_ROOT}/${RNDC_KEY_FILE} ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_KEY_FILE} | cut -d "/" -f 3).MASTER";

                ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSCPConnection.exp remote-copy ${AVAILABLE_MASTER_SERVERS} ${NAMED_ROOT}/${RNDC_KEY_FILE} ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_KEY_FILE} | cut -d "/" -f 3).MASTER;

                ## make sure we got it
                if [ -s ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_KEY_FILE} | cut -d "/" -f 3).MASTER ]
                then
                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSCPConnection.exp remote-copy ${AVAILABLE_MASTER_SERVERS} ${NAMED_ROOT}/${RNDC_KEY_FILE} ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_CONF_FILE} | cut -d "/" -f 3).MASTER";

                    ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSCPConnection.exp remote-copy ${AVAILABLE_MASTER_SERVERS} ${NAMED_ROOT}/${RNDC_CONF_FILE} ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_CONF_FILE} | cut -d "/" -f 3).MASTER;

                    ## make sure we got it
                    if [ -s ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${RNDC_CONF_FILE} | cut -d "/" -f 3).MASTER ]
                    then
                        ## ok, we have our files. now we need to place them
                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Files received. Placing..";

                        for KEYFILE in $(echo ${RNDC_KEY_FILE} | cut -d "/" -f 3) $(echo ${RNDC_CONF_FILE} | cut -d "/" -f 3)
                        do
                            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Transferring ${KEYFILE}..";

                            ## get our checksum
                            OP_FILE_CKSUM=$(cksum ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/${KEYFILE} | awk '{print $1}');

                            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OP_FILE_CKSUM -> ${OP_FILE_CKSUM}";
                            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSCPConnection.exp local-copy ${AVAILABLE_MASTER} ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/${KEYFILE} ${NAMED_ROOT}/etc/dnssec-keys/${KEYFILE};";

                            ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSCPConnection.exp local-copy ${AVAILABLE_MASTER} ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/${KEYFILE} ${NAMED_ROOT}/etc/dnssec-keys/${KEYFILE};

                            ## file copied. validate -
                            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "File copied. Validating..";
                            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSSHConnection.exp ${AVAILABLE_MASTER} \"cksum ${NAMED_ROOT}/etc/dnssec-keys/${KEYFILE}\"";

                            DST_FILE_CKSUM=$(${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSSHConnection.exp ${AVAILABLE_MASTER} "cksum ${NAMED_ROOT}/etc/dnssec-keys/${KEYFILE}"| awk '{print $1}');

                            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "DST_FILE_CKSUM -> ${DST_FILE_CKSUM}";

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
                            if [[ ! -z "${LOCAL_EXECUTION}" && "${LOCAL_EXECUTION}" = "${_TRUE}" ]]
                            then
                                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Local execution is set to TRUE.";

                                ## no trace here, this is a bourne shell script
                                . ${PLUGIN_ROOT_DIR}/${LIB_DIRECTORY}/executors/executeControlRequest.sh -c restart -r -e;
                            else
                                ## MUST execute as root - sudo is best possible option.
                                ## this is NOT required if you are configured to ssh as root.
                                ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSSHConnection.exp ${AVAILABLE_MASTER} "${REMOTE_APP_ROOT}/${LIB_DIRECTORY}/executors/executeControlRequest.sh -c restart -r -e";
                            fi

                            RESTART_CODE=${?};

                            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RESTART_CODE -> ${RESTART_CODE}";

                            if [ ${RESTART_CODE} != 0 ]
                            then
                                ${LOGGER} "WARN" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "named service on ${AVAILABLE_MASTER} failed to restart.";

                                printf "WARNING: named service on ${AVAILABLE_MASTER} failed to restart.";

                                sleep "${MESSAGE_DELAY}";
                            fi
                        fi

                        ## unset keyfile
                        unset KEYFILE;
                    else
                        ## key generation succeeded, but we failed to write the file
                        $(${LOGGER} "ERROR" ${METHOD_NAME} ${CNAME} ${LINENO} "Failed to write out temporary key configuration. Cannot continue.");

                        RETURN_CODE=47;
                    fi
                else
                    ## key generation succeeded, but we failed to write the file
                    $(${LOGGER} "ERROR" ${METHOD_NAME} ${CNAME} ${LINENO} "Failed to write out temporary key configuration. Cannot continue.");

                    RETURN_CODE=47;
                fi
            done

            unset AVAILABLE_MASTERS;
        else
            if [ -z "${AVAILABLE_MASTERS}" ]
            then
                while [ ${A} -ne ${#DNS_SLAVES[@]} ]
                do
                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Now operating on ${DNS_SLAVES[${A}]} .. ";

                    for KEYFILE in $(echo ${RNDC_KEY_FILE} | cut -d "/" -f 3) $(echo ${RNDC_CONF_FILE} | cut -d "/" -f 3)
                    do
                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Transferring ${KEYFILE}..";

                        ## get our checksum
                        OP_FILE_CKSUM=$(cksum ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/${KEYFILE} | awk '{print $1}');

                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OP_FILE_CKSUM -> ${OP_FILE_CKSUM}";
                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSCPConnection.exp local-copy ${DNS_SLAVES[${A}]} ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/${KEYFILE} ${NAMED_ROOT}/etc/dnssec-keys/${KEYFILE};";

                        ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSCPConnection.exp local-copy ${DNS_SLAVES[${A}]} ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/${KEYFILE} ${NAMED_ROOT}/etc/dnssec-keys/${KEYFILE};

                        ## file copied. validate -
                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "File copied. Validating..";
                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSSHConnection.exp ${DNS_SLAVES[${A}]} \"cksum ${NAMED_ROOT}/etc/dnssec-keys/${KEYFILE}\"";

                        DST_FILE_CKSUM=$(${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSSHConnection.exp ${DNS_SLAVES[${A}]} "cksum ${NAMED_ROOT}/etc/dnssec-keys/${KEYFILE}"| awk '{print $1}');

                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "DST_FILE_CKSUM -> ${DST_FILE_CKSUM}";

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
                        if [[ ! -z "${LOCAL_EXECUTION}" && "${LOCAL_EXECUTION}" = "${_TRUE}" ]]
                        then
                            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Local execution is set to TRUE.";

                            ## no trace here, this is a bourne shell script
                            . ${PLUGIN_ROOT_DIR}/${LIB_DIRECTORY}/executors/executeControlRequest.sh -c restart -r -e;
                        else
                            ## MUST execute as root - sudo is best possible option.
                            ## this is NOT required if you are configured to ssh as root.
                            ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSSHConnection.exp ${DNS_SLAVES[${A}]} "${REMOTE_APP_ROOT}/${LIB_DIRECTORY}/executors/executeControlRequest.sh -c restart -r -e";
                        fi

                        RESTART_CODE=${?};

                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RESTART_CODE -> ${RESTART_CODE}";

                        if [ ${RESTART_CODE} != 0 ]
                        then
                            ${LOGGER} "WARN" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "named service on ${DNS_SLAVES[${A}]} failed to restart.";

                            printf "WARNING: named service on ${DNS_SLAVES[${A}]} failed to restart.";

                            sleep "${MESSAGE_DELAY}";
                        fi
                    fi

                    (( A += 1 ));
                done
            else
                while [ ${A} -ne ${#EXT_SLAVES[@]} ]
                do
                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Now operating on ${EXT_SLAVES[${A}]} .. ";

                    for KEYFILE in $(echo ${RNDC_KEY_FILE} | cut -d "/" -f 3) $(echo ${RNDC_CONF_FILE} | cut -d "/" -f 3)
                    do
                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Transferring ${KEYFILE}..";

                        ## get our checksum
                        OP_FILE_CKSUM=$(cksum ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/${KEYFILE} | awk '{print $1}');

                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OP_FILE_CKSUM -> ${OP_FILE_CKSUM}";
                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSCPConnection.exp local-copy ${EXT_SLAVES[${A}]} ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/${KEYFILE} ${NAMED_ROOT}/etc/dnssec-keys/${KEYFILE};";

                        ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSCPConnection.exp local-copy ${EXT_SLAVES[${A}]} ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/${KEYFILE} ${NAMED_ROOT}/etc/dnssec-keys/${KEYFILE};

                        ## file copied. validate -
                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "File copied. Validating..";
                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSSHConnection.exp ${EXT_SLAVES[${A}]} \"cksum ${NAMED_ROOT}/etc/dnssec-keys/${KEYFILE}\"";

                        DST_FILE_CKSUM=$(${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSSHConnection.exp ${EXT_SLAVES[${A}]} "cksum ${NAMED_ROOT}/etc/dnssec-keys/${KEYFILE}" | awk '{print $1}');

                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "DST_FILE_CKSUM -> ${DST_FILE_CKSUM}";

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
                        if [[ ! -z "${LOCAL_EXECUTION}" && "${LOCAL_EXECUTION}" = "${_TRUE}" ]]
                        then
                            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Local execution is set to TRUE.";

                            ## no trace here, this is a bourne shell script
                            . ${PLUGIN_ROOT_DIR}/${LIB_DIRECTORY}/executors/executeControlRequest.sh -c restart -r -e;
                        else
                            ## MUST execute as root - sudo is best possible option.
                            ## this is NOT required if you are configured to ssh as root.
                            ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSSHConnection.exp ${EXT_SLAVES[${A}]} "${REMOTE_APP_ROOT}/${LIB_DIRECTORY}/executors/executeControlRequest.sh -c restart -r -e";
                        fi

                        RESTART_CODE=${?};

                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RESTART_CODE -> ${RESTART_CODE}";

                        if [ ${RESTART_CODE} != 0 ]
                        then
                            ${LOGGER} "WARN" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "named service on ${EXT_SLAVES[${A}]} failed to restart.";

                            printf "WARNING: named service on ${EXT_SLAVES[${A}]} failed to restart.";

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
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Restarting named on ${NAMED_MASTER}..";

            ## call out restart_dns.sh - SysV init {reload} to apply the changes
            if [[ ! -z "${LOCAL_EXECUTION}" && "${LOCAL_EXECUTION}" = "${_TRUE}" ]]
            then
                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Local execution is set to TRUE.";

                ## no trace here, this is a bourne shell script
                . ${PLUGIN_ROOT_DIR}/${LIB_DIRECTORY}/executors/executeControlRequest.sh -c restart -r -e;
            else
                ## MUST execute as root - sudo is best possible option.
                ## this is NOT required if you are configured to ssh as root.
                ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSSHConnection.exp ${NAMED_MASTER} "${REMOTE_APP_ROOT}/${LIB_DIRECTORY}/executors/executeControlRequest.sh -c restart -r -e";
            fi

            RESTART_CODE=${?};

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RESTART_CODE -> ${RESTART_CODE}";

            if [ ${RESTART_CODE} != 0 ]
            then
                ${LOGGER} "WARN" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "named service on ${NAMED_MASTER} failed to restart.";

                printf "WARNING: named service on ${NAMED_MASTER} failed to restart.";

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
        $(${LOGGER} "ERROR" ${METHOD_NAME} ${CNAME} ${LINENO} "Failed to write out temporary key configuration. Cannot continue.");

        RETURN_CODE=47;
    fi

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";


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
    [[ ! -z "${TRACE}" && "${TRACE}" = "${_TRUE}" ]] && set -x;
    local METHOD_NAME="${CNAME}#${0}";

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";
    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Provided arguments: ${@}";

    if [[ ! -z "${IS_TSIG_MGMT_ENABLED}" && "${IS_TSIG_MGMT_ENABLED}" = "${_FALSE}" ]]
    then
        $(${LOGGER} "ERROR" ${METHOD_NAME} ${CNAME} ${LINENO} "TSIG Key management has not been enabled. Cannot continue.");

        return 97;
    fi

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Generating TSIG keyfiles..";

    GENERATION_DATE=$(date +"%m-%d-%Y");

    ## build out rndc keys. we generate two - the local and the remote.
    ## start with the local
    if [[ ! -z "${LOCAL_EXECUTION}" && "${LOCAL_EXECUTION}" = "${_TRUE}" ]]
    then
        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing ${PLUGIN_ROOT_DIR}/${LIB_DIRECTORY}/executors/execute_key_generation.sh -g ${KEYTYPE},${CHANGE_NUM},${IUSER_AUDIT} -e..";

        RET_CODE=$(${PLUGIN_ROOT_DIR}/${LIB_DIRECTORY}/executors/executeKeyGeneration.sh -g ${KEYTYPE},${CHANGE_NUM},${IUSER_AUDIT} -e);
    else
        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSSHConnection.exp ${NAMED_MASTER} \"${REMOTE_APP_ROOT}/${LIB_DIRECTORY}/executors/execute_key_generation.sh -g ${KEYTYPE},${CHANGE_NUM},${IUSER_AUDIT} -e\"";

        RET_CODE=$(${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSSHConnection.exp ${NAMED_MASTER} "${REMOTE_APP_ROOT}/${LIB_DIRECTORY}/executors/executeKeyGeneration.sh -g ${KEYTYPE},${CHANGE_NUM},${IUSER_AUDIT} -e");
    fi

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";

    if [ -z "${RET_CODE}" ]
    then
        ## no key generated
        $(${LOGGER} "ERROR" ${METHOD_NAME} ${CNAME} ${LINENO} "An error occurred while generating the new keys.");

        return 6;
    fi

    ## clean up the files if they exist
    [ -s ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${TRANSFER_KEY_FILE} | cut -d "/" -f 3) ] && rm -rf ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${TRANSFER_KEY_FILE} | cut -d "/" -f 3);
    [ -s ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${TRANSFER_KEY_FILE} | cut -d "/" -f 3) ] && rm -rf ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${TRANSFER_KEY_FILE} | cut -d "/" -f 3);

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Generating TSIG keyfiles..";

    ## we get back the key, but its for the slave servers.
    ## write it out 
    ## this is a local rndc key. build the file
    printf "# keyfile ${TSIG_TRANSFER_KEY} generated by ${IUSER_AUDIT} on ${GENERATION_DATE}\n" >> ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${TRANSFER_KEY_FILE} | cut -d "/" -f 3);
    printf "# change request number ${CHANGE_NUM}\n" >> ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${TRANSFER_KEY_FILE} | cut -d "/" -f 3);
    printf "key \"${TSIG_TRANSFER_KEY}\" {\n" >> ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${TRANSFER_KEY_FILE} | cut -d "/" -f 3);
    printf "    algorithm    hmac-md5;\n" >> ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${TRANSFER_KEY_FILE} | cut -d "/" -f 3);
    printf "    secret       \"${RET_CODE}\";\n" >> ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${TRANSFER_KEY_FILE} | cut -d "/" -f 3);
    printf "};\n\n" >> ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${TRANSFER_KEY_FILE} | cut -d "/" -f 3);

    ## and then write out our master nameserver clauses
    printf "server ${NAMED_MASTER_ADDRESS} {\n" >> ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${TRANSFER_KEY_FILE} | cut -d "/" -f 3);
    printf "    keys { ${TSIG_TRANSFER_KEY}; };\n" >> ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${TRANSFER_KEY_FILE} | cut -d "/" -f 3);
    printf "};\n\n" >> ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${TRANSFER_KEY_FILE} | cut -d "/" -f 3);

    if [ -s ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${TRANSFER_KEY_FILE} | cut -d "/" -f 3) ]
    then
        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${TSIG_TRANSFER_KEY} generation complete.";

        ## now we need to transfer the files out to the slaves
        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Beginning key transfers..";

        A=0;

        while [ ${A} -ne ${#DNS_SLAVES[@]} ]
        do
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Now operating on ${DNS_SLAVES[${A}]} .. ";

            ## get our checksum
            OP_FILE_CKSUM=$(cksum ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${TRANSFER_KEY_FILE} | cut -d "/" -f 3) | awk '{print $1}');

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OP_FILE_CKSUM -> ${OP_FILE_CKSUM}";
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSCPConnection.exp local-copy ${DNS_SLAVES[${A}]} ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${TRANSFER_KEY_FILE} | cut -d \"/\" -f 3) ${NAMED_ROOT}/${TRANSFER_KEY_FILE};";

            ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSCPConnection.exp local-copy ${DNS_SLAVES[${A}]} ${PLUGIN_ROOT_DIR}/${TMP_DIRECTORY}/$(echo ${TRANSFER_KEY_FILE} | cut -d "/" -f 3) ${NAMED_ROOT}/${TRANSFER_KEY_FILE};

            ## file copied. validate -
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "File copied. Validating..";
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSSHConnection.exp ${DNS_SLAVES[${A}]} \"cksum ${NAMED_ROOT}/${TRANSFER_KEY_FILE} | awk '{print $1}'\"";

            DST_FILE_CKSUM=$(${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSSHConnection.exp ${NAMED_MASTER} "cksum ${NAMED_ROOT}/${TRANSFER_KEY_FILE} | awk '{print $1}'");

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "DST_FILE_CKSUM -> ${DST_FILE_CKSUM}";

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
                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Restarting named on ${DNS_SLAVES[${A}]}..";

                ## call out restart_dns.sh - SysV init {reload} to apply the changes
                if [[ ! -z "${LOCAL_EXECUTION}" && "${LOCAL_EXECUTION}" = "${_TRUE}" ]]
                then
                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Local execution is set to TRUE.";

                    ## no trace here, this is a bourne shell script
                    . ${PLUGIN_ROOT_DIR}/${LIB_DIRECTORY}/executors/executeControlRequest.sh -c restart -e;
                else
                    ## MUST execute as root - sudo is best possible option.
                    ## this is NOT required if you are configured to ssh as root.
                    ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSSHConnection.exp ${DNS_SLAVES[${A}]} "${REMOTE_APP_ROOT}/${LIB_DIRECTORY}/executors/executeControlRequest.sh -c restart -e";
                fi

                RESTART_CODE=${?};

                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RESTART_CODE -> ${RESTART_CODE}";

                if [ ${RESTART_CODE} != 0 ]
                then
                    ${LOGGER} "WARN" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "named service on ${DNS_SLAVES[${A}]} failed to restart.";

                    printf "WARNING: named service on ${DNS_SLAVES[${A}]} failed to restart.";

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
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Restarting named on ${NAMED_MASTER}..";

            ## call out restart_dns.sh - SysV init {reload} to apply the changes
            if [[ ! -z "${LOCAL_EXECUTION}" && "${LOCAL_EXECUTION}" = "${_TRUE}" ]]
            then
                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Local execution is set to TRUE.";

                ## no trace here, this is a bourne shell script
                . ${PLUGIN_ROOT_DIR}/${LIB_DIRECTORY}/executors/executeControlRequest.sh -c restart -e;
            else
                ## MUST execute as root - sudo is best possible option.
                ## this is NOT required if you are configured to ssh as root.
                ${APP_ROOT}/${LIB_DIRECTORY}/tcl/runSSHConnection.exp ${NAMED_MASTER} "${REMOTE_APP_ROOT}/${LIB_DIRECTORY}/executors/executeControlRequest.sh -c restart -e";
            fi

            RESTART_CODE=${?};

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RESTART_CODE -> ${RESTART_CODE}";

            if [ ${RESTART_CODE} != 0 ]
            then
                ${LOGGER} "WARN" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "named service on ${NAMED_MASTER} failed to restart.";

                printf "WARNING: named service on ${DNS_SLAVES[${A}]} failed to restart.";

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
        $(${LOGGER} "ERROR" ${METHOD_NAME} ${CNAME} ${LINENO} "Failed to write out temporary key configuration. Cannot continue.");

        RETURN_CODE=47;
    fi

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";


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
    [[ ! -z "${TRACE}" && "${TRACE}" = "${_TRUE}" ]] && set -x;
    local METHOD_NAME="${CNAME}#${0}";

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";
    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Provided arguments: ${@}";

    if [[ ! -z "${IS_DNSSEC_MGMT_ENABLED}" && "${IS_DNSSEC_MGMT_ENABLED}" = "${_FALSE}" ]]
    then
        $(${LOGGER} "ERROR" ${METHOD_NAME} ${CNAME} ${LINENO} "TSIG Key management has not been enabled. Cannot continue.");

        return 97;
    fi

    ## TODO
    RETURN_CODE=1;

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";


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
    [[ ! -z "${TRACE}" && "${TRACE}" = "${_TRUE}" ]] && set -x;
    local METHOD_NAME="${CNAME}#${0}";

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";
    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Provided arguments: ${@}";

    if [[ ! -z "${IS_DNSSEC_MGMT_ENABLED}" && "${IS_DNSSEC_MGMT_ENABLED}" = "${_FALSE}" ]]
    then
        $(${LOGGER} "ERROR" ${METHOD_NAME} ${CNAME} ${LINENO} "TSIG Key management has not been enabled. Cannot continue.");

        return 97;
    fi

    ## TODO
    RETURN_CODE=1;

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
    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Provided arguments: ${@}";

    print "${CNAME} - Performs a DNS query against the nameserver specified.";
    print "Usage: ${CNAME} [ -r ] [ -d ] [ -D ] [ -t ] [ -c <change number> ] [ -e ] [ -h|? ]";
    print " -r    -> Generate new RNDC keys.";
    print " -d    -> Generate new DNSSEC keys.";
    print " -D    -> Generate new DHCPD keys.";
    print " -t    -> Generate new TSIG keys.";
    print " -c    -> Generate new DNSSEC keys.";
    print " -e    -> Execute the request";
    print " -h|-? -> Show this help";

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";


    return 3;
}

while getopts ":rdDtc:eh:" OPTIONS
do
    case "${OPTIONS}" in
        r)
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting GENERATE_RNDC_KEYS..";

            GENERATE_RNDC_KEYS=${_TRUE};

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "GENERATE_RNDC_KEYS -> ${GENERATE_RNDC_KEYS}";
            ;;
        d)
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting GENERATE_DNSSEC_KEYS..";

            GENERATE_DNSSEC_KEYS=${_TRUE};

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "GENERATE_DNSSEC_KEYS -> ${GENERATE_DNSSEC_KEYS}";
            ;;
        d)
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting GENERATE_DHCPD_KEYS..";

            GENERATE_DHCPD_KEYS=${_TRUE};

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "GENERATE_DHCPD_KEYS -> ${GENERATE_DHCPD_KEYS}";
            ;;
        t)
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting GENERATE_TSIG_KEYS..";

            GENERATE_TSIG_KEYS=${_TRUE};

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "GENERATE_TSIG_KEYS -> ${GENERATE_TSIG_KEYS}";
            ;;
        c)
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting CHANGE_NUM..";

            typeset -u CHANGE_NUM=${OPTARG};

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CHANGE_NUM -> ${CHANGE_NUM}";
            ;;
        e)
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Validating request..";

            if [[ -z "${GENERATE_RNDC_KEYS}" || -z "${GENERATE_DNSSEC_KEYS}" || -z "${GENERATE_TSIG_KEYS}" || -z "${GENERATE_DHCPD_KEYS}" ]]
            then
                ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No valid key generation type was provided. Unable to continue processing.";

                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                return 19;
            fi

            if [ -z "${CHANGE_NUM}" ]
            then
                ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No valid change request was provided. Unable to continue processing.";

                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                return 19;
            fi

            ## We have enough information to process the request, continue
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Request validated - executing";
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

            [ "${GENERATE_RNDC_KEYS}" = "${_TRUE}" ] && generateRNDCKeys;
            [ "${GENERATE_DNSSEC_KEYS}" = "${_TRUE}" ] && generateDNSSECKeys;
            [ "${GENERATE_TSIG_KEYS}" = "${_TRUE}" ] && generateTSIGKeys;
            [ "${GENERATE_DHCPD_KEYS}" = "${_TRUE}" ] && generateDHCPDKeys;
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

shift ${OPTIND}-1;


return ${RETURN_CODE};
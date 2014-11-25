#!/usr/bin/env ksh
#==============================================================================
#
#          FILE:  execute_cert_renewal.sh
#         USAGE:  ./execute_cert_renewal.sh [-v] [-b] [-f] [-t] [-p] [-h] [-?]
#   DESCRIPTION:  Process a certificate renewal
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

[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "true" ] && set -x;
[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set -x;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -v;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -v;

## Application constants
CNAME="$(/usr/bin/env basename "${0}")";
SCRIPT_ABSOLUTE_PATH="$(cd "${0%/*}" 2>/dev/null; echo "${PWD}/${0##*/}")";
SCRIPT_ROOT="$(/usr/bin/env dirname "${SCRIPT_ABSOLUTE_PATH}")";
METHOD_NAME="${CNAME}#startup";

[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "true" ] && set +x;
[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set +x;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +v;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +v;

[ -z "${PLUGIN_ROOT_DIR}" ] && [ -f "${SCRIPT_ROOT}/../lib/plugin" ] && . "${SCRIPT_ROOT}/../lib/plugin";

[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "true" ] && set -x;
[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set -x;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -v;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -v;

[ -z "${APP_ROOT}" ] && awk -F "=" '/\<1\>/{print $2}' ${ERROR_MESSAGES} | sed -e 's/^ *//g;s/ *$//g;/^ *#/d;s/#.*//' && return 1;

[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "true" ] && set +x;
[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set +x;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +v;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +v;

[ -f "${PLUGIN_LIB_DIRECTORY}/aliases" ] && . "${PLUGIN_LIB_DIRECTORY}/aliases";
[ -f "${PLUGIN_LIB_DIRECTORY}/functions" ] && . "${PLUGIN_LIB_DIRECTORY}/functions";

[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "true" ] && set -x;
[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set -x;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -v;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -v;

[ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${CNAME} starting up.. Process ID ${$}";
[ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";
[ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Provided arguments: ${*}";

THIS_CNAME="${CNAME}";
unset METHOD_NAME;
unset CNAME;

[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "true" ] && set +x;
[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set +x;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +v;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +v;

## validate the input
"${APP_ROOT}/${LIB_DIRECTORY}/validateSecurityAccess.sh" -a;
typeset -i RET_CODE=${?};

[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "true" ] && set -x;
[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set -x;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -v;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -v;

CNAME="${THIS_CNAME}";
typeset METHOD_NAME="${CNAME}#startup";

[ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";

if [ -z "${RET_CODE}" ] || [ ${RET_CODE} -ne 0 ]
then
    writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Security violation found while executing ${CNAME} by ${IUSER_AUDIT} on host ${SYSTEM_HOSTNAME}";
    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Security configuration blocks execution. Please verify security configuration.";

    awk -F "=" '/\<request.not.authorized\>/{print $2}' ${ERROR_MESSAGES} | sed -e 's/^ *//g;s/ *$//g;/^ *#/d;s/#.*//' && return 1;

    return ${RET_CODE};
fi

unset RET_CODE;
unset METHOD_NAME;
unset CNAME;

[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "true" ] && set +x;
[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set +x;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +v;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +v;

lockProcess "${LOCKFILE}" "${$}";
typeset -i RET_CODE=${?};

[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "true" ] && set -x;
[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set -x;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -v;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -v;

CNAME="${THIS_CNAME}";
METHOD_NAME="${THIS_CNAME}#startup";

[ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";

[ ${RET_CODE} -ne 0 ] && awk -F "=" '/\<application.in.use\>/{print $2}' ${ERROR_MESSAGES} | sed -e 's/^ *//g;s/ *$//g;/^ *#/d;s/#.*//' && return 1;

unset RET_CODE;

#===  FUNCTION  ===============================================================
#          NAME:  apply_iplanet_keystore
#   DESCRIPTION:  Applies updated keystores to a web instance
#    PARAMETERS:  Parameters obtained via command-line flags
#       RETURNS:  0 for positive result, >1 for non-positive
#==============================================================================
function applyiPlanetCertificate
{
    [ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "true" ] && set -x;
    [ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set -x;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -v;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -v;
    typeset METHOD_NAME="${CNAME}#${0}";
    typeset RETURN_CODE=0;

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CERTIFICATE_DATABASE -> ${CERTIFICATE_DATABASE}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CHANGE_NUM -> ${CHANGE_NUM}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "METASLOT_ENABLED -> ${METASLOT_ENABLED}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "IPLANET_ROOT -> ${IPLANET_ROOT}";

    ## First, lets make sure the directory for the provided
    ## BU actually exists
    if [ -d ${IPLANET_ROOT}/${WEB_INSTANCE} ]
    then
        ## pull out the port number. it drives what we alert
        set -A SITE_PORT_NUMBER $(grep -w "${IPLANET_PORT_IDENTIFIER}" \
            ${IPLANET_ROOT}/${WEB_INSTANCE}/${IPLANET_CONFIG_PATH}/${IPLANET_SERVER_CONFIG} | \
            sed -e "s/${IPLANET_PORT_IDENTIFIER}=/@/" | \
            cut -d "@" -f 2 | awk '{print $1}' | sed -e "s/\"//g");

        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "SITE_PORT_NUMBER -> ${SITE_PORT_NUMBER[*]}";

        A=0;

        for PORT in ${SITE_PORT_NUMBER[*]}
        do
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PORT -> ${PORT}";

            if [ ${PORT} -lt ${HIGH_PRIVILEGED_PORT} ]
            then
                ## process is running as a user other than what we expect.
                (( A += 1 ));
            fi
        done

        unset PORT;

        if [ ${A} -eq 0 ]
        then
            IS_PRIVILEGED=${_FALSE};
        else
            IS_PRIVILEGED=${_TRUE};
        fi

        A=0;

        PID_LOG_FILE=$(grep -w ${IPLANET_PID_IDENTIFIER} ${IPLANET_ROOT}/${WEB_INSTANCE}/${IPLANET_CONFIG_PATH}/${IPLANET_CORE_CONFIG} | awk '{print $2}');

        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PID_LOG_FILE -> ${PID_LOG_FILE}";
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "IS_PRIVILEGED -> ${IS_PRIVILEGED}";

        ## make sure file count is zero..
        FILE_COUNT=0;

        for SUFFIX in ${IPLANET_CERT_STORE_KEY_SUFFIX} ${IPLANET_CERT_STORE_CERT_SUFFIX}
        do
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Validating file ${CERTIFICATE_DATABASE}${SUFFIX}..";

            if [ -s "${APP_ROOT}"/${CERTDB_STORE}/${CERTIFICATE_DATABASE}${SUFFIX} ]
            then
                (( FILE_COUNT += 1 ));
            fi
        done

        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "FILE_COUNT -> ${FILE_COUNT}";

        if [ ${FILE_COUNT} -eq 2 ]
        then
            ## both files were received. verify the pkcs file was also received
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate databases received. Validating PKCS#12 file..";

            if [ -s "${APP_ROOT}"/${PKCS12STORE}/${CERTIFICATE_NICKNAME}.pkcs ]
            then
                ## pkcs file is here too. keep going
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PKCS#12 file validated. Continuing..";

                ## reset counters
                A=0;

                PRE_CERT_EXPIRY=$(certutil -L -d "${APP_ROOT}"/${CERTDB_STORE} -P ${CERTIFICATE_DATABASE} -n ${CERTIFICATE_NICKNAME} \
                    | grep "Not After" | cut -d ":" -f 2- | awk '{print $5, $2, $3}');
                PRE_EXPIRY_MONTH=$(echo ${PRE_CERT_EXPIRY} | awk '{print $2}');

                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PRE_PRE_CERT_EXPIRY -> ${PRE_CERT_EXPIRY}";
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PRE_EXPIRY_MONTH -> ${PRE_EXPIRY_MONTH}";

                if [ ! -z "${PRE_CERT_EXPIRY}" ]
                then
                    ## ok, we have a nickname and an expiration date. convert it
                    PRE_EPOCH_EXPIRY=$(returnEpochTime $(echo ${PRE_CERT_EXPIRY} | sed -e "s/${PRE_EXPIRY_MONTH}/$(eval echo \${${PRE_EXPIRY_MONTH}})/"));

                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PRE_EPOCH_EXPIRY -> ${PRE_EPOCH_EXPIRY}";

                    ## ok, we have a web instance. shut it down.
                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Shutting down ${WEB_INSTANCE}..";

                    if [ ! -z "${IS_PRIVILEGED}" ] && [ "${IS_PRIVILEGED}" = "${_FALSE}" ]
                    then
                        SHUTDOWN_OUTPUT=$( { ${IPLANET_ROOT}/${WEB_INSTANCE}/${IPLANET_STOP_SCRIPT}; } 2>&1 )
                    else
                        ## need to use sudo here to start the web
                        SHUTDOWN_OUTPUT=$( { sudo ${IPLANET_SUDO_STOP_WEB} ${IPLANET_ROOT} ${WEB_INSTANCE}; } 2>&1 )
                    fi

                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "SHUTDOWN_OUTPUT -> ${SHUTDOWN_OUTPUT}";

                    if [ -s ${PID_LOG_FILE} ]
                    then
                        SERVICE_PID=$(cat ${PID_LOG_FILE});

                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "SERVICE_PID -> ${SERVICE_PID}";

                        PROCESS_OUTPUT=$(ps | grep ${SERVICE_PID} | grep -v grep | grep -v ${CNAME});

                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PROCESS_OUTPUT -> ${PROCESS_OUTPUT}";

                        if [ ! -z "${PROCESS_OUTPUT}" ]
                        then
                            ## server is running, check to see who its running as
                            IS_RUNNING=${_TRUE};
                        else
                            ## process doesnt appear to be running.
                            IS_RUNNING=${_FALSE};
                        fi
                    else
                        IS_RUNNING=${_FALSE};
                    fi

                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "IS_RUNNING -> ${IS_RUNNING}";

                    if [ ! -z "${IS_RUNNING}" ] && [ "${IS_RUNNING}" = "${_TRUE}" ]
                    then
                        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to stop ${WEB_INSTANCE}. Cannot apply certificate against running webserver.";

                        RETURN_CODE=10;
                    else
                        ## ok, site is down. copy in the new cert db and apply to crypto if necessary
                        ## take a backup..
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Shutdown complete. Backing up keystores..";

                        TARFILE_DATE=$(date +"%m-%d-%Y");
                        BACKUP_FILE=${CERTIFICATE_DATABASE}.${CHANGE_NUM}.${TARFILE_DATE}.${IUSER_AUDIT};

                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backing up files..";

                        ## backup the existing zone files. if we need to back out a change,
                        ## we can do it with these. why tar+gzip ? to carry the process over. we
                        ## want consistency, even when it doesnt make a difference
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "BACKUP_FILE -> ${BACKUP_FILE}";

                        ## tar+gzip
                        [ -s "${APP_ROOT}/${BACKUP_DIRECTORY}"/${BACKUP_FILE}.tar.gz ] && rm -rf "${APP_ROOT}/${BACKUP_DIRECTORY}"/${BACKUP_FILE}.tar.gz;
                        [ -s ${IPLANET_ROOT}/${IPLANET_CERT_DIR}/${CERT_STORE_ARCHIVE}/${CERTIFICATE_NICKNAME}.tar.gz ] && rm -rf ${IPLANET_ROOT}/${IPLANET_CERT_DIR}/${CERT_STORE_ARCHIVE}/${CERTIFICATE_NICKNAME}.tar.gz;

                        ## we do it twice, once for us and once for iplanet
                        (cd ${IPLANET_ROOT}/${IPLANET_CERT_DIR}; tar cf - ${CERTIFICATE_DATABASE}*) | gzip -c > "${APP_ROOT}/${BACKUP_DIRECTORY}"/${BACKUP_FILE}.tar.gz;
                        (cd ${IPLANET_ROOT}/${IPLANET_CERT_DIR}; tar cf - ${CERTIFICATE_DATABASE}*) | gzip -c > ${IPLANET_ROOT}/${IPLANET_CERT_DIR}/${CERT_STORE_ARCHIVE}/${CERTIFICATE_NICKNAME}.tar.gz;

                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backup complete. Validating..";

                        ## make sure backup file got created
                        if [ -s "${APP_ROOT}/${BACKUP_DIRECTORY}"/${BACKUP_FILE}.tar.gz ]
                        then
                            unset BACKUP_FILE;

                            ## ok, we have a backup, copy in the new
                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backup validated. Continuing..";

                            for KEYSTORE in ${IPLANET_CERT_STORE_KEY_SUFFIX} ${IPLANET_CERT_STORE_CERT_SUFFIX}
                            do
                                TMP_FILE_CKSUM=$(cksum "${APP_ROOT}"/${CERTDB_STORE}/${CERTIFICATE_DATABASE}${KEYSTORE} | awk '{print $1}');

                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "TMP_FILE_CKSUM -> ${TMP_FILE_CKSUM}";

                                cp "${APP_ROOT}"/${CERTDB_STORE}/${CERTIFICATE_DATABASE}${KEYSTORE} \
                                    ${IPLANET_ROOT}/${IPLANET_CERT_DIR}/${CERTIFICATE_DATABASE}${KEYSTORE};

                                OP_FILE_CKSUM=$(cksum ${IPLANET_ROOT}/${IPLANET_CERT_DIR}/${CERTIFICATE_DATABASE}${KEYSTORE} | awk '{print $1}');

                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OP_FILE_CKSUM -> ${OP_FILE_CKSUM}";

                                if [ ${OP_FILE_CKSUM} != ${TMP_FILE_CKSUM} ]
                                then
                                    ## checksum mismatch. copy failed.
                                    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Copy keystore FAILURE: Checksum mismatch for ${CERTIFICATE_DATABASE}-${KEYSTORE}";

                                    (( ERROR_COUNT += 1 ));
                                fi
                            done

                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "ERROR_COUNT -> ${ERROR_COUNT}";

                            if [ ${ERROR_COUNT} -eq 0 ]
                            then
                                ## validate the renewal
                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Processing complete. Validating..";

                                POST_CERT_EXPIRY=$(certutil -L -d ${IPLANET_ROOT}/${IPLANET_CERT_DIR} -P ${CERTIFICATE_DATABASE} -n ${CERTIFICATE_NICKNAME} \
                                    | grep "Not After" | cut -d ":" -f 2- | awk '{print $5, $2, $3}');
                                POST_EXPIRY_MONTH=$(echo ${POST_CERT_EXPIRY} | awk '{print $2}');

                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PRE_PRE_CERT_EXPIRY -> ${PRE_CERT_EXPIRY}";
                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "EXPIRY_MONTH -> ${PRE_EXPIRY_MONTH}";

                                if [ ! -z "${POST_CERT_EXPIRY}" ]
                                then
                                    ## ok, we have a nickname and an expiration date. convert it
                                    POST_EPOCH_EXPIRY=$(returnEpochTime $(echo ${POST_CERT_EXPIRY} | sed -e "s/${POST_EXPIRY_MONTH}/$(eval echo \${${POST_EXPIRY_MONTH}})/"));

                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "POST_EPOCH_EXPIRY -> ${POST_EPOCH_EXPIRY}";

                                    if [ ${PRE_EPOCH_EXPIRY} -eq ${POST_EPOCH_EXPIRY} ]
                                    then
                                        writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate Renewal (implementation) by ${IUSER_AUDIT}: Site: ${SITE_DOMAIN_NAME}; Certificate Database: ${CERTIFICATE_DATABASE_STORE}; Certificate Nickname: ${CERTIFICATE_NICKNAME}";

                                        ## ok, we're good to move forward
                                        if [ "${METASLOT_ENABLED}" = "${_TRUE}" ]
                                        then
                                            unset PRE_CERT_EXPIRY;
                                            unset POST_CERT_EXPIRY;

                                            TOKEN_NAME=$(getTokenName);
                                            KEYSTOREDIR=$(getKeyStoreDir | awk '{print $3}');
                                            PRE_CERT_EXPIRY=$(certutil -L -d "${APP_ROOT}"/${CERTDB_STORE} -P ${CERTIFICATE_DATABASE} -n ${CERTIFICATE_NICKNAME} -h "${METASLOT_NAME}" | grep "Not After" | awk '{print $8}');

                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "TOKEN_NAME -> ${TOKEN_NAME}";
                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "KEYSTOREDIR -> ${KEYSTOREDIR}";
                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PRE_CERT_EXPIRY -> ${PRE_CERT_EXPIRY}";
                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing backup of ${KEYSTOREDIR}..";

                                            ## always backup the keystore directory
                                            (cd ${CRYPTO_DATA_DIR}; tar cf - ${KEYSTOREDIR}) | gzip -c > "${APP_ROOT}/${BACKUP_DIRECTORY}"/${TOKEN_NAME}.${BACKUP_FILE}.tar.gz;

                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${KEYSTOREDIR} backup complete. Validating..";

                                            if [ -s "${APP_ROOT}/${BACKUP_DIRECTORY}"/${TOKEN_NAME}.${BACKUP_FILE}.tar.gz ]
                                            then
                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${KEYSTOREDIR} backup complete. Continuing..";

                                                if [ ! -z "${KEYSTORE_BACKUP_ENABLED}" ] && [ "${KEYSTORE_BACKUP_ENABLED}" = "${_TRUE}" ]
                                                then
                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing crypto database backup..";

                                                    BACKUP_FILENAME="${APP_ROOT}"/${BACKUP_DIR}/${TOKEN_NAME}.${IUSER_AUDIT}.$(date +"%m-%d-%Y:%HH:%MM:%SS");

                                                    . "${APP_ROOT}/${LIB_DIRECTORY}"/tcl/run_cert_mgmt.exp backup ${TOKEN_NAME} ${BACKUP_FILENAME};
                                                    RET_CODE=${?}

                                                    if [ ${RET_CODE} -eq 0 ]
                                                    then
                                                        ## verify the file
                                                        if [ -s ${BACKUP_FILENAME} ]
                                                        then
                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Keystore backup executed successfully";

                                                            writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Keystore backup executed by ${IUSER_AUDIT} on $(date +"%Y-%m-%d %H:%M:%S").";
                                                        else
                                                            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Keystore backup failed.";
                                                        fi
                                                    fi
                                                fi

                                                ## see if crypto cleanup is enabled, if its not, none of this matters
                                                if [ ${KEYSTORE_CLEANUP_ENABLED} ]
                                                then
                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Retrieving certificate information from Metaslot..";

                                                    CERT_DATA=$("${APP_ROOT}/${LIB_DIRECTORY}"/tcl/run_cert_renewal.exp ${TOKEN_NAME} ${CERTIFICATE_DATABASE} ${CERTIFICATE_NICKNAME});

                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CERT_DATA -> ${CERT_DATA}";

                                                    if [ ! -z "${CERT_DATA}" ]
                                                    then
                                                        ## we have some data back
                                                        KEY_COUNT=$(echo ${CERT_DATA} | grep "Found" | grep "key" | awk '{print $2}');
                                                        CERT_COUNT=$(echo ${CERT_DATA} | grep "Found" | grep "cert" | awk '{print $2}');

                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "KEY_COUNT -> ${KEY_COUNT}";
                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CERT_COUNT -> ${CERT_COUNT}";

                                                        if [ ! -z "${KEY_COUNT}" ] && [ ! -z "${CERT_COUNT}" ]
                                                        then
                                                            ## key/cert count couldn't be obtained. this could be
                                                            ## because there aren't any in the slot, but not likely
                                                            ## again, non-fatal situation, but should be addressed.
                                                            ## writeLogEntry "AUDIT" "${METHOD_NAME}".
                                                            writeLogEntry writeLogEntry "AUDIT" "${METHOD_NAME}" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No keys/certificates were found in the crypto card to clean. Cannot continue.";

                                                            WARNING_CODE=98;
                                                        else
                                                            ## we have an expected number of certs. xlnt.
                                                            ## remove them.
                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Removing ${KEY_COUNT} keys and ${CERT_COUNT} certs from ${TOKEN_NAME}..";

                                                            ## this is a sensitive task. should probably take a backup here before we start deleting things,
                                                            ## in case we delete too much.
                                                            RET_CODE=$("${APP_ROOT}/${LIB_DIRECTORY}"/tcl/run_cert_renewal.exp delete ${KEY_COUNT} ${CERT_COUNT} ${TOKEN_NAME} ${CERTIFICATE_NICKNAME});

                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";

                                                            if [ ${RET_CODE} -ne 0 ]
                                                            then
                                                                ## removal of the certificate from the slot failed. this is a non-fatal situation,
                                                                ## but it should be corrected anyway. writeLogEntry "AUDIT" "${METHOD_NAME}"
                                                                writeLogEntry writeLogEntry "AUDIT" "${METHOD_NAME}" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Crypto card cleanup action has FAILED. Please execute manually.";

                                                                WARNING_CODE=98;
                                                            else
                                                                ## keys/certs were removed
                                                                writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate Renewal (implementation/metaslot removal) by ${IUSER_AUDIT}: Site: ${SITE_DOMAIN_NAME}; Certificate Database: ${CERTIFICATE_DATABASE_STORE}; Certificate Nickname: ${CERTIFICATE_NICKNAME}";

                                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Removed ${KEY_COUNT} keys and ${CERT_COUNT} certs from ${TOKEN_NAME}. Importing new certificate..";
                                                            fi
                                                        fi
                                                    else
                                                        ## we didnt get back any certificate data from our pktool call.
                                                        ## writeLogEntry "AUDIT" "${METHOD_NAME}" - this is not fatal
                                                        writeLogEntry writeLogEntry "AUDIT" "${METHOD_NAME}" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No keys/certificates were found in the provided keystore for action.";

                                                        WARNING_CODE=98;
                                                    fi
                                                fi

                                                ## certificate(s) was (were) removed. now we can import the new one
                                                ## execute the import
                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && $(writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command " \
                                                    "pk12util -i "${APP_ROOT}/${TMP_DIRECTORY}"/${CERTIFICATE_NICKNAME}.pkcs -h "${METASLOT_NAME}" -d ${CERTSTORE} " \
                                                    "-P ${CERTIFICATE_DATABASE} -k "${APP_ROOT}"/${METASLOT_CERT_DB_PASSFILE} -w "${APP_ROOT}"/${IPLANET_CERT_DB_PASSFILE}";);

                                                pk12util -i "${APP_ROOT}/${TMP_DIRECTORY}"/${CERTIFICATE_NICKNAME}.pkcs -h "${METASLOT_NAME}" -d ${CERTSTORE} \
                                                    -P ${CERTIFICATE_DATABASE} -k "${APP_ROOT}"/${METASLOT_CERT_DB_PASSFILE} -w "${APP_ROOT}"/${IPLANET_CERT_DB_PASSFILE} >> "${APP_ROOT}"/${LOG_DIRECTORY}/pk12util-import.${IUSER_AUDIT}.log 2>&1;
                                                typeset -i RET_CODE=${?};

                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";

                                                if [ ${RET_CODE} -eq 0 ]
                                                then
                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate successfully imported. Validating..";

                                                    unset POST_CERT_EXPIRY;
                                                    unset POST_EXPIRY_MONTH;
                                                    unset POST_EPOCH_EXPIRY;

                                                    POST_CERT_EXPIRY=$(certutil -L -d ${IPLANET_ROOT}/${IPLANET_CERT_DIR} -P ${CERTIFICATE_DATABASE} -n ${CERTIFICATE_NICKNAME} \
                                                        | grep "Not After" | cut -d ":" -f 2- | awk '{print $5, $2, $3}');
                                                    POST_EXPIRY_MONTH=$(echo ${POST_CERT_EXPIRY} | awk '{print $2}');

                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PRE_PRE_CERT_EXPIRY -> ${PRE_CERT_EXPIRY}";
                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "EXPIRY_MONTH -> ${PRE_EXPIRY_MONTH}";

                                                    if [ ! -z "${POST_CERT_EXPIRY}" ]
                                                    then
                                                        ## ok, we have a nickname and an expiration date. convert it
                                                        POST_EPOCH_EXPIRY=$(returnEpochTime $(echo ${POST_CERT_EXPIRY} | sed -e "s/${POST_EXPIRY_MONTH}/$(eval echo \${${POST_EXPIRY_MONTH}})/"));

                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "POST_EPOCH_EXPIRY -> ${POST_EPOCH_EXPIRY}";

                                                        if [ ${PRE_EPOCH_EXPIRY} -eq ${POST_EPOCH_EXPIRY} ]
                                                        then
                                                            ## success!
                                                            writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate Renewal (implementation/metaslot import) by ${IUSER_AUDIT}: Site: ${SITE_DOMAIN_NAME}; Certificate Database: ${CERTIFICATE_DATABASE_STORE}; Certificate Nickname: ${CERTIFICATE_NICKNAME}";

                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate successfully imported.";
                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Starting up ${WEB_INSTANCE}..";

                                                            if [ ! -z "${IS_PRIVILEGED}" ] && [ "${IS_PRIVILEGED}" = "${_FALSE}" ]
                                                            then
                                                                STARTUP_OUTPUT=$( { ${IPLANET_ROOT}/${WEB_INSTANCE}/${IPLANET_START_SCRIPT}; } 2>&1 )
                                                            else
                                                                ## need to use sudo here to start the web
                                                                STARTUP_OUTPUT=$( { sudo ${IPLANET_SUDO_START_WEB} ${IPLANET_ROOT} ${WEB_INSTANCE}; } 2>&1 )
                                                            fi

                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "STARTUP_OUTPUT -> ${STARTUP_OUTPUT}";

                                                            if [ -s ${PID_LOG_FILE} ]
                                                            then
                                                                ## web started
                                                                SERVICE_PID=$(cat ${PID_LOG_FILE});

                                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PID_LOG_FILE -> ${PID_LOG_FILE}";
                                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "SERVICE_PID -> ${SERVICE_PID}";

                                                                PROCESS_OUTPUT=$(ps -auxwww | grep -w ${SERVICE_PID} | grep -v grep);

                                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PROCESS_OUTPUT -> ${PROCESS_OUTPUT}";

                                                                if [ -z "${PROCESS_OUTPUT}" ]
                                                                then
                                                                    ## server failed to properly start
                                                                    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${WEB_INSTANCE} appears to be down. Restart attempt has failed: ${STARTUP_OUTPUT}";

                                                                    RETURN_CODE=10;
                                                                else
                                                                    ## complete. clean up databases
                                                                    for SUFFIX in ${IPLANET_CERT_STORE_KEY_SUFFIX} ${IPLANET_CERT_STORE_CERT_SUFFIX}
                                                                    do
                                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Removing temporary file "${APP_ROOT}"/${CERTDB_STORE}/${CERTIFICATE_DATABASE}${SUFFIX}..";

                                                                        rm -rf "${APP_ROOT}"/${CERTDB_STORE}/${CERTIFICATE_DATABASE}${SUFFIX} > /dev/null 2>&1;
                                                                    done

                                                                    ## cleanup pkcs file
                                                                    rm -rf "${APP_ROOT}"/${PKCS12STORE}/${CERTIFICATE_NICKNAME}.pkcs > /dev/null 2>&1;

                                                                    RETURN_CODE=0;
                                                                fi
                                                            else
                                                                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Web instance failed to start. Please start manually.";

                                                                RETURN_CODE=40;
                                                            fi
                                                        else
                                                            ## certificate renewal against metaslot failed
                                                            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate import into metaslot FAILED. Please try again.";

                                                            RETURN_CODE=7;
                                                        fi
                                                    else
                                                        ## failed to import certificate into metaslot
                                                        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate import into metaslot FAILED - Certificate expiration date is equal to or less than previous. Please try again.";

                                                        RETURN_CODE=7;
                                                    fi
                                                else
                                                    ## failed to import certificate into metaslot
                                                    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate import into metaslot FAILED. Please try again.";

                                                    RETURN_CODE=7;
                                                fi
                                            else
                                                ## no backup file. dont continue
                                                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Keystore backup FAILED. Cannot continue.";

                                                RETURN_CODE=20;
                                            fi
                                        else
                                            ## no metaslot, we're done here
                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Metaslot not enabled. Renewal complete.";
                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Starting up ${WEB_INSTANCE}..";

                                            if [ ! -z "${IS_PRIVILEGED}" ] && [ "${IS_PRIVILEGED}" = "${_FALSE}" ]
                                            then
                                                STARTUP_OUTPUT=$( { ${IPLANET_ROOT}/${WEB_INSTANCE}/${IPLANET_START_SCRIPT}; } 2>&1 )
                                            else
                                                ## need to use sudo here to start the web
                                                STARTUP_OUTPUT=$( { sudo ${IPLANET_SUDO_START_WEB} ${IPLANET_ROOT} ${WEB_INSTANCE}; } 2>&1 )
                                            fi

                                            [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && typeset -ft $(typeset +f);

                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "STARTUP_OUTPUT -> ${STARTUP_OUTPUT}";

                                            if [ -s ${PID_LOG_FILE} ]
                                            then
                                                ## web started
                                                SERVICE_PID=$(cat ${PID_LOG_FILE});

                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PID_LOG_FILE -> ${PID_LOG_FILE}";
                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "SERVICE_PID -> ${SERVICE_PID}";

                                                PROCESS_OUTPUT=$(ps -auxwww | grep -w ${SERVICE_PID} | grep -v grep);

                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PROCESS_OUTPUT -> ${PROCESS_OUTPUT}";

                                                if [ -z "${PROCESS_OUTPUT}" ]
                                                then
                                                    ## server failed to properly start
                                                    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${WEB_INSTANCE} appears to be down. Restart attempt has failed: ${STARTUP_OUTPUT}";

                                                    RETURN_CODE=10;
                                                else
                                                    for SUFFIX in ${IPLANET_CERT_STORE_KEY_SUFFIX} ${IPLANET_CERT_STORE_CERT_SUFFIX}
                                                    do
                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Removing temporary file "${APP_ROOT}"/${CERTDB_STORE}/${CERTIFICATE_DATABASE}${SUFFIX}..";

                                                        rm -rf "${APP_ROOT}"/${CERTDB_STORE}/${CERTIFICATE_DATABASE}${SUFFIX} > /dev/null 2>&1;
                                                    done

                                                    ## cleanup pkcs file
                                                    rm -rf "${APP_ROOT}"/${PKCS12STORE}/${CERTIFICATE_NICKNAME}.pkcs > /dev/null 2>&1;

                                                    RETURN_CODE=0;
                                                fi
                                            else
                                                ## startup failed
                                                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${WEB_INSTANCE} appears to be down. Restart attempt has failed: ${STARTUP_OUTPUT}";

                                                RETURN_CODE=10;
                                            fi
                                        fi
                                    else
                                        ## certificate renewal appears to have failed
                                        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate renewal failed. New expiration date matches or is not greater than the existing. Please try again.";

                                        RETURN_CODE=8;
                                    fi
                                else
                                    ## failed to obtain post-copy expiry
                                    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Unable to obtain post-copy certificate expiration. Cannot continue.";

                                    RETURN_CODE=8;
                                fi
                            else
                                ## cert copy failed
                                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate keystore copy failed. Please try again.";

                                RETURN_CODE=8;
                            fi
                        else
                            ## backup failed
                            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to create a certificate database backup. Unable to continue.";

                            RETURN_CODE=9;
                        fi
                    fi
                fi
            else
                ## pkcs file wasnt received, cant continue
                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Unable to locate configuration directory for ${WEB_INSTANCE}. Cannot continue.";

                RETURN_CODE=35;
            fi
        else
            ## certificate databases werent received, cant continue
            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Unable to locate new certificate databases. Cannot continue.";

            RETURN_CODE=34;
        fi
    else
        ## couldnt find the instance to work on
        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Unable to locate configuration directory for ${WEB_INSTANCE}. Cannot continue.";

        RETURN_CODE=31;
    fi

    if [ ${RETURN_CODE} -eq 0 ]
    then
        if [ ! -z "${WARNING_CODE}" ]
        then
            RETURN_CODE=${WARNING_CODE};
        fi
    fi

    A=0;
    FILE_COUNT=0;
    unset RET_CODE;
    unset WARNING_CODE;
    unset KEY_COUNT;
    unset CERT_COUNT;
    unset CERT_DATA;
    unset BACKUP_FILENAME;
    unset ERROR_COUNT;
    unset OP_FILE_CKSUM;
    unset TMP_FILE_CKSUM;
    unset KEYSTORE;
    unset TARFILE_DATE;
    unset WS_ROOT;
    unset PRE_CERT_EXPIRY;
    unset POST_CERT_EXPIRY;
    unset PROCESS_OUTPUT;
    unset SERVICE_PID;
    unset PID_LOG_FILE;
    unset STARTUP_OUTPUT;
    unset POST_CERT_EXPIRY;
    unset RET_CODE;
    unset NOTIFY_WARNING;
    unset KEY_COUNT;
    unset CERT_COUNT;
    unset CERT_DATA;
    unset TOKEN_NAME;
    unset POST_EPOCH_EXPIRY;
    unset KEYSTOREDIR;
    unset PRE_CERT_EXPIRY;
    unset POST_EXPIRY_MONTH;
    unset POST_CERT_EXPIRY;
    unset OP_FILE_CKSUM;
    unset TMP_FILE_CKSUM;
    unset KEYSTORE;
    unset TARFILE_DATE;
    unset BACKUP_FILE;
    unset PID_LOG_FILE;
    unset SHUTDOWN_OUTPUT;
    unset PRE_EPOCH_EXPIRY;
    unset PRE_EXPIRY_MONTH;
    unset PRE_CERT_EXPIRY;
    unset SUFFIX;
    unset IS_PRIVILEGED;
    unset PORT;
    unset SITE_PORT_NUMBER;

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";
}

function applyIHSKeystore
{
    [ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "true" ] && set -x;
    [ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set -x;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -v;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -v;
    typeset METHOD_NAME="${CNAME}#${0}";
    typeset RETURN_CODE=0;

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "INSTANCE_NAME -> ${CERTIFICATE_DATABASE}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CHANGE_NUM -> ${CHANGE_NUM}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "METASLOT_ENABLED -> ${METASLOT_ENABLED}";

    ## reset counters
    A=0;

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Validating "${IHS_PATH}"/${CERTIFICATE_DATABASE}..";

    ## First, lets make sure the directory for the provided
    ## BU actually exists
    if [ -d "${IHS_PATH}"/${CERTIFICATE_DATABASE} ]
    then
        ## ok, we have a web instance. shut it down.
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Shutting down ${CERTIFICATE_DATABASE}..";

        RET_CODE=$("${IHS_PATH}/${BIN_DIRECTORY}"/${IHS_START_SCRIPT} -d "${IHS_PATH}" -d ${CERTIFICATE_DATABASE} -k stop);

        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";

        if [ ${RET_CODE} -eq 0 ]
        then
            ## ok, site is down. copy in the new cert db and apply to crypto if necessary
            ## take a backup..
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Shutdown complete. Backing up keystores..";

            TARFILE_DATE=$(date +"%m-%d-%Y");
            BACKUP_FILE=${CERTIFICATE_DATABASE}.${CHANGE_NUM}.${TARFILE_DATE}.${IUSER_AUDIT};

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backing up files..";

            ## backup the existing zone files. if we need to back out a change,
            ## we can do it with these. why tar+gzip ? to carry the process over. we
            ## want consistency, even when it doesnt make a difference
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "BACKUP_FILE -> ${BACKUP_FILE}";

            ## tar+gzip
            tar cf "${IHS_PATH}"/${IHS_CERT_DIR}/${CERT_BACKUP_DIR}/${BACKUP_FILE}.tar -C "${IHS_PATH}"/${IHS_CERT_DIR} \
                ${CERTIFICATE_DATABASE}* > /dev/null 2>&1;
            gzip "${IHS_PATH}"/${IHS_CERT_DIR}/${CERT_BACKUP_DIR}/${BACKUP_FILE}.tar > /dev/null 2>&1;

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backup complete. Validating..";

            ## make sure backup file got created
            if [ -s "${IHS_PATH}"/${IHS_CERT_DIR}/${CERT_BACKUP_DIR}/${BACKUP_FILE}.tar.gz ]
            then
                unset BACKUP_FILE;

                ## ok, we have a backup, copy in the new
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backup validated. Continuing..";

                for KEYSTORE in ${IHS_DB_STASH_SUFFIX} ${IHS_DB_REQ_SUFFIX} ${IHS_DB_CRT_SUFFIX}
                do
                    TMP_FILE_CKSUM=$(cksum "${APP_ROOT}/${TMP_DIRECTORY}"/${CERTIFICATE_DATABASE}${KEYSTORE} | awk '{print $1}');

                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "TMP_FILE_CKSUM -> ${TMP_FILE_CKSUM}";

                    cp "${APP_ROOT}/${TMP_DIRECTORY}"/${CERTIFICATE_DATABASE}${KEYSTORE} \
                        ${IPLANET_ROOT}/${IPLANET_CERT_DIR}/${CERTIFICATE_DATABASE}${KEYSTORE};

                    OP_FILE_CKSUM=$(cksum ${IPLANET_ROOT}/${IPLANET_CERT_DIR}/${CERTIFICATE_DATABASE}${KEYSTORE} | awk '{print $1}');

                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OP_FILE_CKSUM -> ${OP_FILE_CKSUM}";

                    if [ ${OP_FILE_CKSUM} != ${TMP_FILE_CKSUM} ]
                    then
                        ## checksum mismatch. copy failed.
                        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Copy keystore FAILURE: Checksum mismatch for ${CERTIFICATE_DATABASE}${KEYSTORE}";

                        (( ERROR_COUNT += 1 ));
                    fi
                done

                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "ERROR_COUNT -> ${ERROR_COUNT}";

                if [ ${ERROR_COUNT} -eq 0 ]
                then
                    writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate Renewal (implementation) by ${IUSER_AUDIT}: Site: ${SITE_DOMAIN_NAME}; Certificate Database: ${CERTIFICATE_DATABASE_STORE}; Certificate Nickname: ${CERTIFICATE_NICKNAME}";

                    ## thats it folks. bring up the web
                    RET_CODE=$("${IHS_PATH}/${BIN_DIRECTORY}"/${IHS_START_SCRIPT} -d "${IHS_PATH}" -d ${CERTIFICATE_DATABASE} -k stop);

                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";

                    if [ ${RET_CODE} -eq 0 ]
                    then
                        ## all done, web is up, cert is installed
                        RETURN_CODE=0;
                    else
                        ## server startup failed, but the cert databases were installed correctly
                        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate renewal succeeded, but web startup failed. Please start the service manually.";

                        RETURN_CODE=23;
                    fi
                else
                    ## cert copy failed
                    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate keystore copy failed. Please try again.";

                    RETURN_CODE=8;
                fi
            else
                ## backup failed
                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to create a certificate database backup. Unable to continue.";

                RETURN_CODE=9;
            fi
        else
            ## site stop failed
            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to stop ${SITE_HOSTNAME}. Cannot apply certificate against running webserver.";

            RETURN_CODE=10;
        fi
    else
        ## couldnt find the instance to work on
        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Unable to locate configuration directory for ${SITE_HOSTNAME}. Cannot continue.";

        RETURN_CODE=11;
    fi
}

#===  FUNCTION  ===============================================================
#          NAME:  usage
#   DESCRIPTION:  Processes and implements a DNS site failover
#    PARAMETERS:  Parameters obtained via command-line flags
#       RETURNS:  0 for positive result, >1 for non-positive
#==============================================================================
function usage
{
    [ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "true" ] && set -x;
    [ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set -x;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -v;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -v;
    typeset METHOD_NAME="${CNAME}#${0}";
    typeset RETURN_CODE=0;

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";

    echo "${THIS_CNAME} - Execute a site failover";
    echo "Usage: ${THIS_CNAME} [ -w web instance ] [ -p platform ] [ -r region ] [ -d database ] [ -n cert nickname ] " \
        "[ -i username ] [ -c change order ] [ -e ] [-h] [-?]";
    echo " -w     The web instance name to operate against";
    echo " -p     The webserver platform type";
    echo " -r     The region associated with this website (eg ist, stg)";
    echo " -d     The certificate database to be utilized";
    echo " -n     The certificate nickname to renew";
    echo " -i     The username associated with this request";
    echo " -c     The change order associated with this request";
    echo " -e     Execute the request";
    echo " -h|-?  Show this help";

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

    return 3;
}

[ -z "${PLUGIN_ROOT_DIR}" ] && [ -s "${SCRIPT_ROOT}/../${LIB_DIRECTORY}/plugin" ] && . "${SCRIPT_ROOT}/../${LIB_DIRECTORY}/plugin";
[ -z "${PLUGIN_ROOT_DIR}" ] && exit 1

[ ${#} -eq 0 ] && usage&& RETURN_CODE=${?};

METHOD_NAME="${CNAME}#startup";

[ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${CNAME} starting up.. Process ID ${$}";
[ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Provided arguments: ${*}";
[ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";

while getopts ":w:p:r:d:n:i:c:eh" OPTIONS 2>/dev/null
do
    case "${OPTIONS}" in
        w)
            ## capture the webinstance
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting WEB_INSTANCE..";

            WEB_INSTANCE=${OPTARG};

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "WEB_INSTANCE -> ${WEB_INSTANCE}";
            ;;
        p)
            ## capture the platform
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting WS_PLATFORM..";

            WS_PLATFORM=${OPTARG}; # This will be the BU to move

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "WS_PLATFORM -> ${WS_PLATFORM}";
            ;;
        r)
            ## capture the region
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting WS_ROOT..";

            ## Capture the business unit
            WS_ROOT=${OPTARG};

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "WS_ROOT -> ${WS_ROOT}";
            ;;
        d)
            ## capture the certdb
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting CERTIFICATE_DATABASE..";

            CERTIFICATE_DATABASE=${OPTARG};

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CERTIFICATE_DATABASE -> ${CERTIFICATE_DATABASE}";
            ;;
        n)
            ## capture the webinstance
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting CERTIFICATE_NICKNAME..";

            ## Capture the business unit
            CERTIFICATE_NICKNAME=${OPTARG};

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CERTIFICATE_NICKNAME -> ${CERTIFICATE_NICKNAME}";
            ;;
        i)
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting IUSER_AUDIT..";

            ## Capture the business unit
            typeset -u IUSER_AUDIT="${OPTARG}";

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "IUSER_AUDIT -> ${IUSER_AUDIT}";
            ;;
        c)
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting CHANGE_NUM..";

            typeset -u CHANGE_NUM="${OPTARG}";

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CHANGE_NUM -> ${CHANGE_NUM}";
            ;;
        e)
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Validating request..";

            ## Make sure we have enough information to process
            ## and execute
            if [ -z "${WEB_INSTANCE}" ]
            then
                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No web instance was provided. Unable to continue processing.";
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                RETURN_CODE=26;
            elif [ -z "${WS_PLATFORM}" ]
            then
                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No webserver platform was provided. Unable to continue processing.";
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                RETURN_CODE=21;
            elif [ -z "${WS_ROOT}" ]
            then
                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No installation root was provided. Unable to continue processing.";
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                RETURN_CODE=27;
            elif [ -z "${CERTIFICATE_DATABASE}" ]
            then
                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No certificate database was provided. Unable to continue processing.";
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                RETURN_CODE=9;
            elif [ -z "${CERTIFICATE_NICKNAME}" ]
            then
                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No certificate nickname was provided. Unable to continue processing.";
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                RETURN_CODE=10;
            elif [ -z "${IUSER_AUDIT}" ]
            then
                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Unable to audit user account. Unable to continue processing.";
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                RETURN_CODE=20;
            elif [ -z "${CHANGE_NUM}" ]
            then
                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No change order number was provided. Unable to continue processing.";
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                RETURN_CODE=12;
            else
                ## We have enough information to process the request, continue
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Request validated - executing.";
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                if [ "${WS_PLATFORM}" = "${IPLANET_TYPE_IDENTIFIER}" ]
                then
                    applyiPlanetCertificate;
                elif [ "${WS_PLATFORM}" = "${IHS_TYPE_IDENTIFIER}" ]
                then
                    applyIHSCertificate;
                else
                    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "The webserver platform provided is not supported. Unable to continue processing.";

                    RETURN_CODE=28;
                fi
            fi
            ;;
        h)
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

            usage&& RETURN_CODE=${?};
            ;;
        [\?])
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

            usage&& RETURN_CODE=${?};
            ;;
        *)
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

            usage&& RETURN_CODE=${?};
            ;;
    esac
done


echo ${RETURN_CODE};
exit ${RETURN_CODE};

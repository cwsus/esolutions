#!/usr/bin/env ksh
#==============================================================================
#
#          FILE:  execute_decom.sh
#         USAGE:  ./execute_decom.sh
#   DESCRIPTION:  Adds and updates various indicators utilized by named, as
#                 well as adding auditory information.
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

trap 'set +v; set +x' INT TERM EXIT;

[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "true" ] && set -x;
[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set -x;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -v;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -v;

## Application constants
CNAME="$(/usr/bin/env basename "${0}")";
SCRIPT_ABSOLUTE_PATH="$(cd "${0%/*}" 2>/dev/null; echo "${PWD}/${0##*/}")";
SCRIPT_ROOT="$(/usr/bin/env dirname "${SCRIPT_ABSOLUTE_PATH}")";
METHOD_NAME="${CNAME}#startup";
LOCKFILE=$(mktemp);

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
#          NAME:  decom_master_bu
#   DESCRIPTION:  Searches for and replaces audit indicators for the provided
#                 filename.
#    PARAMETERS:  Parameters obtained via command-line flags
#          NAME:  usage for positive result, >1 for non-positive
#==============================================================================
function decom_master_bu
{
[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "true" ] && set -x;
[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set -x;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -v;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -v;
    typeset METHOD_NAME="${CNAME}#${0}";
    typeset RETURN_CODE=0;

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Provided arguments: ${*}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Performing decommission of ${BUSINESS_UNIT}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Validating that requested directories/files exist..";

    typeset CHANGE_DATE=$(date +"%m-%d-%Y");
    typeset TARFILE_NAME=${GROUP_ID}${BUSINESS_UNIT}.${CHANGE_NUM}.${CHANGE_DATE}.${REQUESTING_USER}.tar.gz;
    typeset LC_BUSINESS_UNIT=$(tr "[A-Z]" "[a-z]" <<< ${BUSINESS_UNIT});
    typeset CONF_FILE=$(cut -d "/" -f 5 <<< ${NAMED_CONF_FILE});

    ## need to make sure the provided information actually exists in the install
    if [ -d "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_MASTER_ROOT}/${GROUP_ID}${BUSINESS_UNIT} ]
    then
        ## take our backups
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backing up zone files..";

        (cd "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_MASTER_ROOT}; tar cf - ${GROUP_ID}${BUSINESS_UNIT}/) | gzip -c > "${PLUGIN_BACKUP_DIR}"/${TARFILE_NAME};

        if [ -s "${PLUGIN_BACKUP_DIR}"/${TARFILE_NAME} ]
        then
            ## ok, we should now have a backup of the business unit zone files.
            ## take a backup of the business unit conf file.
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backing up configuration files..";

            cp "${NAMED_ROOT}/${NAMED_CONF_DIR}/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}" \
                "${PLUGIN_BACKUP_DIR}/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}.${CHANGE_NUM}";

            if [ -s "${PLUGIN_BACKUP_DIR}/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}.${CHANGE_NUM}" ]
            then
                ## ok, now we should have a backup of the bu conf. lets take a backup of the decom conf file if it exists.
                ## if it doesnt exist, no backup is taken because there isnt anything to back up..
                if [ -s "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" ]
                then
                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backing up decom configuration files..";

                    cp "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" "${PLUGIN_BACKUP_DIR}/${DECOM_CONF_FILE}.${CHANGE_NUM}";

                    ## verify it...
                    if [ ! -s "${PLUGIN_BACKUP_DIR}/${DECOM_CONF_FILE}.${CHANGE_NUM}" ]
                    then
                        ## it didnt back up. send an error.
                        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to back up decom config file. Cannot continue.";
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                        RETURN_CODE=57;
                    else
                        ## ok, thats all our backups. keep going.
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backup complete. Continuing..";

                        ## excellent! now we're going to pipe the contents of the existing biz conf file into the decom conf file
                        ## clear the variable
                        set -A ZONE_LISTING;

                        ## loop through all the zones in the conf file and pull them out. we'll need them later.
                        for ZONE_ENTRY in $(grep zone "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} | cut -d "\"" -f 2)
                        do
                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "ZONE_ENTRY -> ${ZONE_ENTRY}";

                            set -A ZONE_LISTING ${ZONE_LISTING[*]} ${ZONE_ENTRY};
                        done

                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "ZONE_LISTING -> ${ZONE_LISTING[*]}";
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone names obtained. Now obtaining file names..";

                        ## clear the variable
                        set -A FILE_LISTING;

                        ## loop through all the filenames in the conf file and pull them out
                        for ZONE_ENTRY in $(grep file "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} | cut -d "\"" -f 2)
                        do
                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "ZONE_ENTRY -> ${ZONE_ENTRY}";

                            set -A FILE_LISTING ${FILE_LISTING[*]} $(sed -e "s^${GROUP_ID}${BUSINESS_UNIT}^${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT}^g" <<< ${ZONE_ENTRY});
                        done

                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "FILE_LISTING -> ${FILE_LISTING[*]}";
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "File listing obtained. Proceeding..";

                        ## make sure our variables were populated
                        if [ ! -z "${ZONE_LISTING}" ] && [ ! -z "${FILE_LISTING}" ]
                        then
                            ## we have data, check it
                            if [ ${#ZONE_LISTING[*]} -ne ${#FILE_LISTING[*]} ]
                            then
                                ## we have a mismatch. there should be an equal number of files to zones, this indicates a problem.
                                ## we should fail out here, and this should be done before any other processing gets done
                                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Data mismatch detected. Throwing error.";

                                RETURN_CODE=70;
                            else
                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "File and zone lists agree. Continuing..";

                                ## make sure d is zero
                                D=0;
                                ERROR_COUNTER=0;

                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Creating working copy of decom config file..";

                                ## take a copy of the decom conf file and operate on it
                                TMPFILE=$(mktemp);

                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "TMPFILE -> ${TMPFILE}";

                                cp "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" ${TMPFILE};

                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Creation complete. Verifying..";

                                ## make sure its there..
                                if [ -s ${TMPFILE} ]
                                then
                                    ## it is. good.
                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Creation complete. Proceeding..";

                                    while [ ${D} -ne ${#ZONE_LISTING[*]} ]
                                    do
                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Adding configuration entry for ${ZONE_LISTING[${D}]}";

                                        ## add the entry...
                                        echo "zone \"${ZONE_LISTING[${D}]}\" IN {" >> ${TMPFILE};
                                        echo "    type              master;" >> ${TMPFILE};
                                        echo "    file              \"${FILE_LISTING[${D}]}\";" >> ${TMPFILE};
                                        echo "    allow-update      { none; };" >> ${TMPFILE};
                                        echo "    allow-transfer    { key ${TSIG_TRANSFER_KEY}; };" >> ${TMPFILE};
                                        echo "};\n" >> ${TMPFILE};

                                        ## confirm the entry..
                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Entry added. Confirming..";

                                        ## ok, so it should be in there now. verify -
                                        if [ $(grep -c "zone \"${ZONE_LISTING[${D}]}\" IN {" TMPFILE) -eq 1 ]
                                        then
                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Added ${ZONE_LISTING[${D}]} to the decom config file.";
                                        else
                                            ## entry did not get added. hmm.
                                            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to add configuration for ${ZONE_LISTING[${D}]} to the decom config file.";

                                            (( ERROR_COUNTER += 1 ));
                                        fi

                                        (( D += 1 ));
                                    done

                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Completed zone processing. Verifying..";

                                    ## ok, processing is complete. check the error counter and make sure its zero.
                                    if [ ${ERROR_COUNTER} -eq 0 ]
                                    then
                                        ## successfully modified our decom conf file, and it contains all the data it should have.
                                        ## now we copy our decom conf file into place...
                                        cp ${TMPFILE} "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}";

                                        ## copy complete. lets make sure they match..
                                        OP_CHECKSUM=$(cksum "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" | awk '{print $1}');
                                        TMP_CHECKSUM=$(cksum ${TMPFILE} | awk '{print $1}');

                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OP_CHECKSUM -> ${OP_CHECKSUM}";
                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "TMP_CHECKSUM -> ${TMP_CHECKSUM}";

                                        ## we have our checksums, match them.
                                        if [ ${OP_CHECKSUM} -ne ${TMP_CHECKSUM} ]
                                        then
                                            ## they do not match. this means something broke.
                                            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to properly copy the decom configuration file. Unable to continue.";
                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                            RETURN_CODE=70;
                                        else
                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Checksums match. Continuing..";

                                            ## ok, we've gotten the new data into the installation.
                                            ## its time to move the files.
                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Moving business unit zone directory..";

                                            ## make sure the decom dir exists.. if not, create it
                                            [ ! -d "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_MASTER_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR} ] && mkdir "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_MASTER_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR};

                                            mv "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_MASTER_ROOT}/${GROUP_ID}${BUSINESS_UNIT} "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_MASTER_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT};

                                            ## and make sure it got moved.
                                            if [ -d "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_MASTER_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT} ]
                                            then
                                                ## ok, cool. we can keep going
                                                ## we can now remove the bu conf file, and copy our temporary decom conf file into place
                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Removing business unit config file..";

                                                rm -rf "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME};

                                                ## and make sure its gone...
                                                if [ ! -s "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} ] &&
                                                    [ ! -f "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} ]
                                                then
                                                    ## it is. lets remove it from the named.conf file and add in (if necessary)
                                                    ## the decom conf file.
                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Removal complete. Backing up primary configuration..";

                                                    ## back it up..
                                                    cp ${NAMED_CONF_FILE} "${PLUGIN_BACKUP_DIR}/${CONF_FILE}.${CHANGE_NUM}";

                                                    ## and confirm..
                                                    if [ -s "${PLUGIN_BACKUP_DIR}/${CONF_FILE}.${CHANGE_NUM}" ]
                                                    then
                                                        ## backup complete. operate.
                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backup complete. Creating working copy of named configuration..";

                                                        ## create copy of named conf file..
                                                        cp ${NAMED_CONF_FILE} "${PLUGIN_TMP_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}";

                                                        ## and make sure it happened..
                                                        if [ -s "${PLUGIN_TMP_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}" ]
                                                        then
                                                            ## good. lets keep going
                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Working copy created. Operating..";
                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Removing entry from ${NAMED_CONF_FILE}..";

                                                            if [ $(grep -c "${DECOM_CONF_FILE}" "${PLUGIN_TMP_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}") -eq 0 ]
                                                            then
                                                                ## its not there, so lets replace the existing business unit filename
                                                                ## with the decom filename
                                                                sed -e "s^/"${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}^/"${NAMED_CONF_DIR}/${DECOM_CONF_FILE}"^" \
                                                                    "${PLUGIN_WORK_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}" > "${PLUGIN_TMP_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}";
                                                            else
                                                                ## its already there, so just remove the entry
                                                                sed -e "/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}/d" \
                                                                    "${PLUGIN_WORK_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}" > "${PLUGIN_TMP_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}";
                                                            fi

                                                            ## move the file back to where it was before..
                                                            mv "${PLUGIN_TMP_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}" "${PLUGIN_WORK_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}";

                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Entry removed. Validating..";

                                                            ## and make sure it was removed..
                                                            if [ $(grep -c ${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} "${PLUGIN_TMP_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}") -eq 0 ]
                                                            then
                                                                ## we should be done here. make sure our decom include is in, and if so, copy the file
                                                                if [ $(grep -c "${DECOM_CONF_FILE}" "${PLUGIN_TMP_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}") -ne 0 ]
                                                                then
                                                                    ## its there. lets move.
                                                                    cp "${PLUGIN_TMP_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}" ${NAMED_CONF_FILE};

                                                                    ## and checksum...
                                                                    TMP_CONF_CKSUM=$(cksum "${PLUGIN_TMP_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}" | awk '{print $1}');
                                                                    OP_CONF_CKSUM=$(cksum ${NAMED_CONF_FILE} | awk '{print $1}');

                                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "TMP_CONF_CKSUM -> ${TMP_CONF_CKSUM}";
                                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OP_CONF_CKSUM -> ${OP_CONF_CKSUM}";

                                                                    ## and validate...
                                                                    if [ ${TMP_CONF_CKSUM} -eq ${OP_CONF_CKSUM} ]
                                                                    then
                                                                        ## ok, checksums match, we're super.
                                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Decommission of ${ZONE_NAME} from "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} complete.";
                                                                        writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone ${ZONE_NAME} decommissioned by ${REQUESTING_USER} per change ${CHANGE_NUM} on $(date +"%m-%d-%Y") at $(date +"%H:%M:%S")";

                                                                        RETURN_CODE=0;
                                                                    else
                                                                        ## ok, so our checksums dont match. this probably means that the named conf in tmp/ didnt
                                                                        ## copy to where its supposed to go. this *should* be ok, but does warrant some review. writeLogEntry "AUDIT" "${METHOD_NAME}".
                                                                        writeLogEntry writeLogEntry "AUDIT" "${METHOD_NAME}" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CHECKSUM MISMATCH: Failed to validate that named configuration file was updated.";

                                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Decommission of ${ZONE_NAME} from "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} complete.";
                                                                        writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone ${ZONE_NAME} decommissioned by ${REQUESTING_USER} per change ${CHANGE_NUM} on $(date +"%m-%d-%Y") at $(date +"%H:%M:%S")";

                                                                        RETURN_CODE=72;
                                                                    fi
                                                                else
                                                                    ## failed to pipe in the decom include. error
                                                                    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to include the decom configuration information in the master configuration file. Unable to proceed.";
                                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                                                    RETURN_CODE=72;
                                                                fi
                                                            else
                                                                ## include statement didnt get removed. this will result in named errors. fail.
                                                                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to backup the primary configuration file. Cannot continue.";
                                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                                                RETURN_CODE=70;
                                                            fi
                                                        else
                                                            ## couldnt create a copy. fail.
                                                            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to backup the primary configuration file. Cannot continue.";
                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                                            RETURN_CODE=47;
                                                        fi
                                                    else
                                                        ## couldnt backup named config. fail
                                                        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to backup the primary configuration file. Cannot continue.";
                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                                        RETURN_CODE=57;
                                                    fi
                                                else
                                                    ## failed to remove bu conf file. writeLogEntry "AUDIT" "${METHOD_NAME}", but dont fail.
                                                    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to remove the business unit configuration file.";
                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                                    RETURN_CODE=70;
                                                fi
                                            else
                                                ## failed to relocate zone files. throw an error
                                                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to relocate zone files for business unit.";
                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                                RETURN_CODE=70;
                                            fi
                                        fi
                                    else
                                        ## our error counter is not zero. this means something didnt get added.
                                        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "One or more zone entries did not add properly. Unable to continue.";
                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                        RETURN_CODE=70;
                                    fi
                                else
                                    ## we wont operate on the hot copy. not for this kind of work.
                                    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to create a working copy of "${DECOM_CONF_FILE}". Unable to continue.";
                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                    RETURN_CODE=47;
                                fi
                            fi
                        else
                            ## hmm. one or both of our variables is blank. hmm. fail it, we dont have the necessary information to proceed
                            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Necessary data to proceed with the operation was not found. Please try again.";
                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                            RETURN_CODE=28;
                        fi
                    fi
                else
                    ## we have no decom file to backup. so we'll keep chugging along.
                    ## ok, thats all our backups. keep going.
                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backup complete. Continuing..";

                    ## excellent! now we're going to pipe the contents of the existing biz conf file into the decom conf file
                    ## clear the variable
                    set -A ZONE_LISTING;

                    ## loop through all the zones in the conf file and pull them out. we'll need them later.
                    for ZONE_ENTRY in $(grep zone "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} | cut -d "\"" -f 2)
                    do
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "ZONE_ENTRY -> ${ZONE_ENTRY}";

                        set -A ZONE_LISTING ${ZONE_LISTING[*]} ${ZONE_ENTRY};
                    done

                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "ZONE_LISTING -> ${ZONE_LISTING[*]}";
                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone names obtained. Now obtaining file names..";

                    ## clear the variable
                    set -A FILE_LISTING;

                    ## loop through all the filenames in the conf file and pull them out
                    for ZONE_ENTRY in $(grep file "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} | cut -d "\"" -f 2)
                    do
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "ZONE_ENTRY -> ${ZONE_ENTRY}";

                        set -A FILE_LISTING ${FILE_LISTING[*]} $(sed -e "s^${GROUP_ID}${BUSINESS_UNIT}^${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT}^g" <<< ${ZONE_ENTRY});
                    done

                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "FILE_LISTING -> ${FILE_LISTING[*]}";
                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "File listing obtained. Proceeding..";

                    ## make sure our variables were populated
                    if [ ! -z "${ZONE_LISTING}" ] && [ ! -z "${FILE_LISTING}" ]
                    then
                        ## we have data, check it
                        if [ ${#ZONE_LISTING[*]} -ne ${#FILE_LISTING[*]} ]
                        then
                            ## we have a mismatch. there should be an equal number of files to zones, this indicates a problem.
                            ## we should fail out here, and this should be done before any other processing gets done
                            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Data mismatch detected. Throwing error.";

                            RETURN_CODE=70;
                        else
                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "File and zone lists agree. Continuing..";

                            ## make sure d is zero
                            D=0;
                            ERROR_COUNTER=0;

                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Creating working copy of decom config file..";

                            ## take a copy of the decom conf file and operate on it
                            ## theres no decom conf file to copy from, so touch create what we need
                            touch "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";

                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Creation complete. Verifying..";

                            ## make sure its there..
                            if [ -f "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}" ]
                            then
                                ## it is. good.
                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Creation complete. Proceeding..";

                                while [ ${D} -ne ${#ZONE_LISTING[*]} ]
                                do
                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Adding configuration entry for ${ZONE_LISTING[${D}]}";

                                    ## add the entry...
                                    echo "zone \"${ZONE_LISTING[${D}]}\" IN {" >> ${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE};
                                    echo "    type              master;" >> ${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE};
                                    echo "    file              \"${FILE_LISTING[${D}]}\";" >> ${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE};
                                    echo "    allow-update      { none; };" >> ${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE};
                                    echo "    allow-transfer    { key ${TSIG_TRANSFER_KEY}; };" >> ${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE};
                                    echo "};\n" >> ${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE};

                                    ## confirm the entry..
                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Entry added. Confirming..";

                                    ## ok, so it should be in there now. verify -
                                    if [ $(grep -c "zone \"${ZONE_LISTING[${D}]}\" IN {" "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}") -eq 1 ]
                                    then
                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Added ${ZONE_LISTING[${D}]} to the decom config file.";
                                    else
                                        ## entry did not get added. hmm.
                                        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to add configuration for ${ZONE_LISTING[${D}]} to the decom config file.";

                                        (( ERROR_COUNTER += 1 ));
                                    fi

                                    (( D += 1 ));
                                done

                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Completed zone processing. Verifying..";

                                ## ok, processing is complete. check the error counter and make sure its zero.
                                if [ ${ERROR_COUNTER} -eq 0 ]
                                then
                                    ## successfully modified our decom conf file, and it contains all the data it should have.
                                    ## now we copy our decom conf file into place...
                                    cp "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}" "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}";

                                    ## copy complete. lets make sure they match..
                                    OP_CHECKSUM=$(cksum "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" | awk '{print $1}');
                                    TMP_CHECKSUM=$(cksum "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}" | awk '{print $1}');

                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OP_CHECKSUM -> ${OP_CHECKSUM}";
                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "TMP_CHECKSUM -> ${TMP_CHECKSUM}";

                                    ## we have our checksums, match them.
                                    if [ ${OP_CHECKSUM} -ne ${TMP_CHECKSUM} ]
                                    then
                                        ## they do not match. this means something broke.
                                        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to properly copy the decom configuration file. Unable to continue.";

                                        RETURN_CODE=70;
                                    else
                                        ## ok, we've gotten the new data into the installation.
                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Checksums match. Continuing..";

                                        ## its time to move the files.
                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Moving business unit zone directory..";

                                        ## make sure the decom dir exists.. if not, create it
                                        [ ! -d "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_MASTER_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR} ] && mkdir "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_MASTER_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR};

                                        mv "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_MASTER_ROOT}/${GROUP_ID}${BUSINESS_UNIT} "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_MASTER_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT};

                                        ## and make sure it got moved.
                                        if [ -d "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_MASTER_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT} ]
                                        then
                                            ## ok, cool. we can keep going
                                            ## we can now remove the bu conf file, and copy our temporary decom conf file into place
                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Removing business unit config file..";

                                            rm -rf "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME};

                                            ## and make sure its gone...
                                            if [ ! -s "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} ] &&
                                                [ ! -f "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} ]
                                            then
                                                ## it is. lets remove it from the named.conf file and add in (if necessary)
                                                ## the decom conf file.
                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Removal complete. Backing up primary configuration..";

                                                ## back it up..
                                                cp ${NAMED_CONF_FILE} "${PLUGIN_BACKUP_DIR}/${CONF_FILE}.${CHANGE_NUM}";

                                                ## and confirm..
                                                if [ -s "${PLUGIN_BACKUP_DIR}/${CONF_FILE}.${CHANGE_NUM}" ]
                                                then
                                                    ## backup complete. operate.
                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backup complete. Creating working copy of named configuration..";

                                                    ## create copy of named conf file..
                                                    cp ${NAMED_CONF_FILE} "${PLUGIN_TMP_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}";

                                                    ## and make sure it happened..
                                                    if [ -s "${PLUGIN_TMP_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}" ]
                                                    then
                                                        ## good. lets keep going
                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Working copy created. Operating..";
                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Removing entry from ${NAMED_CONF_FILE}..";

                                                        ## check for an entry in named.conf for the decom config file. if its not
                                                        ## there then add it
                                                        if [ $(grep -c "${DECOM_CONF_FILE}" "${PLUGIN_TMP_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}") -eq 0 ]
                                                        then
                                                            ## its not there, so lets replace the existing business unit filename
                                                            ## with the decom filename
                                                            sed -e "s^/"${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}^/"${NAMED_CONF_DIR}/${DECOM_CONF_FILE}"^" \
                                                                "${PLUGIN_WORK_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}" > "${PLUGIN_TMP_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}";
                                                        else
                                                            ## its already there, so just remove the entry
                                                            sed -e "/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}/d" \
                                                                "${PLUGIN_WORK_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}" > "${PLUGIN_TMP_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}";
                                                        fi

                                                        ## move the file back to where it was before..
                                                        mv "${PLUGIN_TMP_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}" "${PLUGIN_WORK_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}";

                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Entry removed. Validating..";

                                                        ## and make sure it was removed..
                                                        if [ $(grep -c ${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} "${PLUGIN_TMP_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}") -eq 0 ]
                                                        then
                                                            ## we should be done here. make sure our decom include is in, and if so, copy the file
                                                            if [ $(grep -c "${DECOM_CONF_FILE}" "${PLUGIN_TMP_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}") -ne 0 ]
                                                            then
                                                                ## its there. lets move.
                                                                cp "${PLUGIN_TMP_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}" ${NAMED_CONF_FILE};

                                                                ## and checksum...
                                                                TMP_CONF_CKSUM=$(cksum "${PLUGIN_TMP_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}" | awk '{print $1}');
                                                                OP_CONF_CKSUM=$(cksum ${NAMED_CONF_FILE} | awk '{print $1}');

                                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "TMP_CONF_CKSUM -> ${TMP_CONF_CKSUM}";
                                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OP_CONF_CKSUM -> ${OP_CONF_CKSUM}";

                                                                ## and validate...
                                                                if [ ${TMP_CONF_CKSUM} -eq ${OP_CONF_CKSUM} ]
                                                                then
                                                                    ## ok, checksums match, we're super.
                                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Decommission of ${ZONE_NAME} from "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} complete.";
                                                                    writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone ${ZONE_NAME} decommissioned by ${REQUESTING_USER} per change ${CHANGE_NUM} on $(date +"%m-%d-%Y") at $(date +"%H:%M:%S")";

                                                                    RETURN_CODE=0;
                                                                else
                                                                    ## ok, so our checksums dont match. this probably means that the named conf in tmp/ didnt
                                                                    ## copy to where its supposed to go. this *should* be ok, but does warrant some review. writeLogEntry "AUDIT" "${METHOD_NAME}".
                                                                    writeLogEntry writeLogEntry "AUDIT" "${METHOD_NAME}" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CHECKSUM MISMATCH: Failed to validate that named configuration file was updated.";

                                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Decommission of ${ZONE_NAME} from "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} complete.";
                                                                    writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone ${ZONE_NAME} decommissioned by ${REQUESTING_USER} per change ${CHANGE_NUM} on $(date +"%m-%d-%Y") at $(date +"%H:%M:%S")";

                                                                    RETURN_CODE=72;
                                                                fi
                                                            else
                                                                ## failed to pipe in the decom include. error
                                                                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to include the decom configuration information in the master configuration file. Unable to proceed.";
                                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                                                RETURN_CODE=72;
                                                            fi
                                                        else
                                                            ## include statement didnt get removed. this will result in named errors. fail.
                                                            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to backup the primary configuration file. Cannot continue.";
                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                                            RETURN_CODE=70;
                                                        fi
                                                    else
                                                        ## couldnt create a copy. fail.
                                                        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to backup the primary configuration file. Cannot continue.";
                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                                        RETURN_CODE=47;
                                                    fi
                                                else
                                                    ## couldnt backup named config. fail
                                                    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to backup the primary configuration file. Cannot continue.";
                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                                    RETURN_CODE=57;
                                                fi
                                            else
                                                ## failed to remove bu conf file. writeLogEntry "AUDIT" "${METHOD_NAME}", but dont fail.
                                                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to remove the business unit configuration file.";
                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                                RETURN_CODE=70;
                                            fi
                                        else
                                            ## failed to relocate zone files. throw an error
                                            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to relocate zone files for business unit.";
                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                            RETURN_CODE=70;
                                        fi
                                    fi
                                else
                                    ## our error counter is not zero. this means something didnt get added.
                                    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "One or more zone entries did not add properly. Unable to continue.";
                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                    RETURN_CODE=70;
                                fi
                            else
                                ## we wont operate on the hot copy. not for this kind of work.
                                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to create a working copy of "${DECOM_CONF_FILE}". Unable to continue.";
                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                RETURN_CODE=47;
                            fi
                        fi
                    else
                        ## hmm. one or both of our variables is blank. hmm. fail it, we dont have the necessary information to proceed
                        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Necessary data to proceed with the operation was not found. Please try again.";
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                        RETURN_CODE=28;
                    fi
                fi
            else
                ## failed to take a bu conf backup. error.
                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to create business unit configuration backup. Cannot continue.";
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                RETURN_CODE-57;
            fi
        else
            ## failed to take a bu zone backup. error.
            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to create zone configuration backup. Cannot continue.";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

            RETURN_CODE=57;
        fi
    else
        ## we were provided information necessary to perform the work, but the information given doesnt map to
        ## actual files/directories on the filesystem. cant operate with nothing to operate against
        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to locate neccessary operating directories. Cannot continue.";
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

        RETURN_CODE=10;
    fi

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

    ## remove any tmp files
    rm -rf "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
    rm -rf "${PLUGIN_TMP_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}";

    unset END_LINE_NUMBER;
    unset START_LINE_NUMBER;
    unset ZONEFILE_NAME;
    unset CONF_TMP_CKSUM;
    unset CONF_OP_CKSUM;
    unset TMP_CONF_CKSUM;
    unset OP_CONF_CKSUM;
    unset CHANGE_DATE;
    unset CHANGE_NUM;

    [ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "true" ] && set +x;
    [ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set +x;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +v;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +v;

    return ${RETURN_CODE};
}

#===  FUNCTION  ===============================================================
#          NAME:  decom_slave_bu
#   DESCRIPTION:  Searches for and replaces audit indicators for the provided
#                 filename.
#    PARAMETERS:  Parameters obtained via command-line flags
#          NAME:  usage for positive result, >1 for non-positive
#==============================================================================
function decom_slave_bu
{
[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "true" ] && set -x;
[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set -x;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -v;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -v;
    typeset METHOD_NAME="${CNAME}#${0}";
    typeset RETURN_CODE=0;

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Provided arguments: ${*}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Performing decommission of ${BUSINESS_UNIT}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Validating that requested directories/files exist..";

    typeset CHANGE_DATE=$(date +"%m-%d-%Y");
    typeset TARFILE_NAME=${GROUP_ID}${BUSINESS_UNIT}.${CHANGE_NUM}.${CHANGE_DATE}.${REQUESTING_USER}.tar.gz;
    typeset LC_BUSINESS_UNIT=$(tr "[A-Z]" "[a-z]" <<< ${BUSINESS_UNIT});
    typeset CONF_FILE=$(cut -d "/" -f 5 <<< ${NAMED_CONF_FILE});

    ## need to make sure the provided information actually exists in the install
    if [ -d "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${BUSINESS_UNIT} ]
    then
        ## take our backups
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backing up zone files..";

        (cd "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}; tar cf - ${GROUP_ID}${BUSINESS_UNIT}/) | gzip -c > "${PLUGIN_BACKUP_DIR}"/${TARFILE_NAME};

        if [ -s "${PLUGIN_BACKUP_DIR}"/${TARFILE_NAME} ]
        then
            ## ok, we should now have a backup of the business unit zone files.
            ## take a backup of the business unit conf file.
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backing up configuration files..";

            cp "${NAMED_ROOT}/${NAMED_CONF_DIR}/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}" \
                "${PLUGIN_BACKUP_DIR}/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}.${CHANGE_NUM}";

            if [ -s "${PLUGIN_BACKUP_DIR}/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}.${CHANGE_NUM}" ]
            then
                ## ok, now we should have a backup of the bu conf. lets take a backup of the decom conf file if it exists.
                ## if it doesnt exist, no backup is taken because there isnt anything to back up..
                if [ -s "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" ]
                then
                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backing up decom configuration files..";

                    cp "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" "${PLUGIN_BACKUP_DIR}/${DECOM_CONF_FILE}.${CHANGE_NUM}";

                    ## verify it...
                    if [ ! -s "${PLUGIN_BACKUP_DIR}/${DECOM_CONF_FILE}.${CHANGE_NUM}" ]
                    then
                        ## it didnt back up. send an error.
                        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to back up decom config file. Cannot continue.";
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                        RETURN_CODE=57;
                    else
                        ## ok, thats all our backups. keep going.
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backup complete. Continuing..";

                        ## excellent! now we're going to pipe the contents of the existing biz conf file into the decom conf file
                        ## clear the variable
                        set -A ZONE_LISTING;

                        ## loop through all the zones in the conf file and pull them out. we'll need them later.
                        for ZONE_ENTRY in $(grep zone "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} | cut -d "\"" -f 2)
                        do
                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "ZONE_ENTRY -> ${ZONE_ENTRY}";

                            set -A ZONE_LISTING ${ZONE_LISTING[*]} ${ZONE_ENTRY};
                        done

                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "ZONE_LISTING -> ${ZONE_LISTING[*]}";
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone names obtained. Now obtaining file names..";

                        ## clear the variable
                        set -A FILE_LISTING;

                        ## loop through all the filenames in the conf file and pull them out
                        for ZONE_ENTRY in $(grep file "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} | cut -d "\"" -f 2)
                        do
                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "ZONE_ENTRY -> ${ZONE_ENTRY}";

                            set -A FILE_LISTING ${FILE_LISTING[*]} $(sed -e "s^${GROUP_ID}${BUSINESS_UNIT}^${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT}^g" <<< ${ZONE_ENTRY});
                        done

                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "FILE_LISTING -> ${FILE_LISTING[*]}";
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "File listing obtained. Proceeding..";

                        ## make sure our variables were populated
                        if [ ! -z "${ZONE_LISTING}" ] && [ ! -z "${FILE_LISTING}" ]
                        then
                            ## we have data, check it
                            if [ ${#ZONE_LISTING[*]} -ne ${#FILE_LISTING[*]} ]
                            then
                                ## we have a mismatch. there should be an equal number of files to zones, this indicates a problem.
                                ## we should fail out here, and this should be done before any other processing gets done
                                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Data mismatch detected. Throwing error.";

                                RETURN_CODE=70;
                            else
                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "File and zone lists agree. Continuing..";

                                ## make sure d is zero
                                D=0;
                                ERROR_COUNTER=0;

                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Creating working copy of decom config file..";

                                ## take a copy of the decom conf file and operate on it
                                cp "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";

                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Creation complete. Verifying..";

                                ## make sure its there..
                                if [ -s "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}" ]
                                then
                                    ## it is. good.
                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Creation complete. Proceeding..";

                                    while [ ${D} -ne ${#ZONE_LISTING[*]} ]
                                    do
                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Adding configuration entry for ${ZONE_LISTING[${D}]}";

                                        ## add the entry...
                                        echo "zone \"${ZONE_LISTING[${D}]}\" IN {" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                                        echo "    type              master;" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                                        echo "    file              \"${FILE_LISTING[${D}]}\";" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                                        echo "    allow-update      { none; };" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                                        echo "    allow-transfer    { key ${TSIG_TRANSFER_KEY}; };" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                                        echo "};\n" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";

                                        ## confirm the entry..
                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Entry added. Confirming..";

                                        ## ok, so it should be in there now. verify -
                                        if [ $(grep -c "zone \"${ZONE_LISTING[${D}]}\" IN {" "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}") -eq 1 ]
                                        then
                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Added ${ZONE_LISTING[${D}]} to the decom config file.";
                                        else
                                            ## entry did not get added. hmm.
                                            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to add configuration for ${ZONE_LISTING[${D}]} to the decom config file.";

                                            (( ERROR_COUNTER += 1 ));
                                        fi

                                        (( D += 1 ));
                                    done

                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Completed zone processing. Verifying..";

                                    ## ok, processing is complete. check the error counter and make sure its zero.
                                    if [ ${ERROR_COUNTER} -eq 0 ]
                                    then
                                        ## successfully modified our decom conf file, and it contains all the data it should have.
                                        ## now we copy our decom conf file into place...
                                        cp "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}" "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}";

                                        ## copy complete. lets make sure they match..
                                        OP_CHECKSUM=$(cksum "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" | awk '{print $1}');
                                        TMP_CHECKSUM=$(cksum "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}" | awk '{print $1}');

                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OP_CHECKSUM -> ${OP_CHECKSUM}";
                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "TMP_CHECKSUM -> ${TMP_CHECKSUM}";

                                        ## we have our checksums, match them.
                                        if [ ${OP_CHECKSUM} -ne ${TMP_CHECKSUM} ]
                                        then
                                            ## they do not match. this means something broke.
                                            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to properly copy the decom configuration file. Unable to continue.";

                                            RETURN_CODE=70;
                                        else
                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Checksums match. Continuing..";

                                            ## ok, we've gotten the new data into the installation.
                                            ## its time to move the files.
                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Moving business unit zone directory..";

                                            ## make sure the decom dir exists.. if not, create it
                                            [ ! -d "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR} ] && mkdir "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR};

                                            mv "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${BUSINESS_UNIT} "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT};

                                            ## and make sure it got moved.
                                            if [ -d "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT} ]
                                            then
                                                ## ok, cool. we can keep going
                                                ## we can now remove the bu conf file, and copy our temporary decom conf file into place
                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Removing business unit config file..";

                                                rm -rf "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME};

                                                ## and make sure its gone...
                                                if [ ! -s "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} ] &&
                                                    [ ! -f "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} ]
                                                then
                                                    ## it is. lets remove it from the named.conf file and add in (if necessary)
                                                    ## the decom conf file.
                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Removal complete. Backing up primary configuration..";

                                                    ## back it up..
                                                    cp ${NAMED_CONF_FILE} "${PLUGIN_BACKUP_DIR}/${CONF_FILE}.${CHANGE_NUM}";

                                                    ## and confirm..
                                                    if [ -s "${PLUGIN_BACKUP_DIR}/${CONF_FILE}.${CHANGE_NUM}" ]
                                                    then
                                                        ## backup complete. operate.
                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backup complete. Creating working copy of named configuration..";

                                                        ## create copy of named conf file..
                                                        cp ${NAMED_CONF_FILE} "${PLUGIN_TMP_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}";

                                                        ## and make sure it happened..
                                                        if [ -s "${PLUGIN_TMP_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}" ]
                                                        then
                                                            ## good. lets keep going
                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Working copy created. Operating..";
                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Removing entry from ${NAMED_CONF_FILE}..";

                                                            if [ $(grep -c "${DECOM_CONF_FILE}" "${PLUGIN_TMP_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}") -eq 0 ]
                                                            then
                                                                ## its not there, so lets replace the existing business unit filename
                                                                ## with the decom filename
                                                                sed -e "s^/"${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}^/"${NAMED_CONF_DIR}/${DECOM_CONF_FILE}"^" \
                                                                    "${PLUGIN_WORK_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}" > "${PLUGIN_TMP_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}";
                                                            else
                                                                ## its already there, so just remove the entry
                                                                sed -e "/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}/d" \
                                                                    "${PLUGIN_WORK_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}" > "${PLUGIN_TMP_DIRECTORY}/${CONF_FILE}.${CHANGE_NUM}";
                                                            fi

                                                            ## move the file back to where it was before..
                                                            mv "${PLUGIN_TMP_DIRECTORY}"/${CONF_FILE}.${CHANGE_NUM} "${PLUGIN_WORK_DIRECTORY}"/${CONF_FILE}.${CHANGE_NUM};

                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Entry removed. Validating..";

                                                            ## and make sure it was removed..
                                                            if [ $(grep -c ${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} "${PLUGIN_WORK_DIRECTORY}"/${CONF_FILE}.${CHANGE_NUM}) -eq 0 ]
                                                            then
                                                                ## we should be done here. make sure our decom include is in, and if so, copy the file
                                                                if [ $(grep -c "${DECOM_CONF_FILE}" "${PLUGIN_TMP_DIRECTORY}"/${CONF_FILE}.${CHANGE_NUM}) -ne 0 ]
                                                                then
                                                                    ## its there. lets move.
                                                                    cp "${PLUGIN_TMP_DIRECTORY}"/${CONF_FILE}.${CHANGE_NUM} ${NAMED_CONF_FILE};

                                                                    ## and checksum...
                                                                    TMP_CONF_CKSUM=$(cksum "${PLUGIN_TMP_DIRECTORY}"/${CONF_FILE}.${CHANGE_NUM} | awk '{print $1}');
                                                                    OP_CONF_CKSUM=$(cksum ${NAMED_CONF_FILE} | awk '{print $1}');

                                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "TMP_CONF_CKSUM -> ${TMP_CONF_CKSUM}";
                                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OP_CONF_CKSUM -> ${OP_CONF_CKSUM}";

                                                                    ## and validate...
                                                                    if [ ${TMP_CONF_CKSUM} -eq ${OP_CONF_CKSUM} ]
                                                                    then
                                                                        ## ok, checksums match, we're super.
                                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Decommission of ${ZONE_NAME} from "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} complete.";
                                                                        writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone ${ZONE_NAME} decommissioned by ${REQUESTING_USER} per change ${CHANGE_NUM} on $(date +"%m-%d-%Y") at $(date +"%H:%M:%S")";

                                                                        RETURN_CODE=0;
                                                                    else
                                                                        ## ok, so our checksums dont match. this probably means that the named conf in tmp/ didnt
                                                                        ## copy to where its supposed to go. this *should* be ok, but does warrant some review. writeLogEntry "AUDIT" "${METHOD_NAME}".
                                                                        writeLogEntry writeLogEntry "AUDIT" "${METHOD_NAME}" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CHECKSUM MISMATCH: Failed to validate that named configuration file was updated.";

                                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Decommission of ${ZONE_NAME} from "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} complete.";
                                                                        writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone ${ZONE_NAME} decommissioned by ${REQUESTING_USER} per change ${CHANGE_NUM} on $(date +"%m-%d-%Y") at $(date +"%H:%M:%S")";

                                                                        RETURN_CODE=72;
                                                                    fi
                                                                else
                                                                    ## failed to pipe in the decom include. error
                                                                    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to include the decom configuration information in the master configuration file. Unable to proceed.";
                                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                                                    RETURN_CODE=72;
                                                                fi
                                                            else
                                                                ## include statement didnt get removed. this will result in named errors. fail.
                                                                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to backup the primary configuration file. Cannot continue.";
                                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                                                RETURN_CODE=70;
                                                            fi
                                                        else
                                                            ## couldnt create a copy. fail.
                                                            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to backup the primary configuration file. Cannot continue.";
                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                                            RETURN_CODE=47;
                                                        fi
                                                    else
                                                        ## couldnt backup named config. fail
                                                        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to backup the primary configuration file. Cannot continue.";
                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                                        RETURN_CODE=57;
                                                    fi
                                                else
                                                    ## failed to remove bu conf file. writeLogEntry "AUDIT" "${METHOD_NAME}", but dont fail.
                                                    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to remove the business unit configuration file.";
                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                                    RETURN_CODE=70;
                                                fi
                                            else
                                                ## failed to relocate zone files. throw an error
                                                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to relocate zone files for business unit.";
                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                                RETURN_CODE=70;
                                            fi
                                        fi
                                    else
                                        ## our error counter is not zero. this means something didnt get added.
                                        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "One or more zone entries did not add properly. Unable to continue.";
                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                        RETURN_CODE=70;
                                    fi
                                else
                                    ## we wont operate on the hot copy. not for this kind of work.
                                    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to create a working copy of "${DECOM_CONF_FILE}". Unable to continue.";
                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                    RETURN_CODE=47;
                                fi
                            fi
                        else
                            ## hmm. one or both of our variables is blank. hmm. fail it, we dont have the necessary information to proceed
                            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Necessary data to proceed with the operation was not found. Please try again.";
                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                            RETURN_CODE=28;
                        fi
                    fi
                else
                    ## we have no decom file to backup. so we'll keep chugging along.
                    ## ok, thats all our backups. keep going.
                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backup complete. Continuing..";

                    ## excellent! now we're going to pipe the contents of the existing biz conf file into the decom conf file
                    ## clear the variable
                    set -A ZONE_LISTING;

                    ## loop through all the zones in the conf file and pull them out. we'll need them later.
                    for ZONE_ENTRY in $(grep zone "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} | cut -d "\"" -f 2)
                    do
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "ZONE_ENTRY -> ${ZONE_ENTRY}";

                        set -A ZONE_LISTING ${ZONE_LISTING[*]} ${ZONE_ENTRY};
                    done

                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "ZONE_LISTING -> ${ZONE_LISTING[*]}";
                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone names obtained. Now obtaining file names..";

                    ## clear the variable
                    set -A FILE_LISTING;

                    ## loop through all the filenames in the conf file and pull them out
                    for ZONE_ENTRY in $(grep file "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} | cut -d "\"" -f 2)
                    do
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "ZONE_ENTRY -> ${ZONE_ENTRY}";

                        set -A FILE_LISTING ${FILE_LISTING[*]} $(sed -e "s^${GROUP_ID}${BUSINESS_UNIT}^${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT}^g" <<< ${ZONE_ENTRY});
                    done

                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "FILE_LISTING -> ${FILE_LISTING[*]}";
                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "File listing obtained. Proceeding..";

                    ## make sure our variables were populated
                    if [ ! -z "${ZONE_LISTING}" ] && [ ! -z "${FILE_LISTING}" ]
                    then
                        ## we have data, check it
                        if [ ${#ZONE_LISTING[*]} -ne ${#FILE_LISTING[*]} ]
                        then
                            ## we have a mismatch. there should be an equal number of files to zones, this indicates a problem.
                            ## we should fail out here, and this should be done before any other processing gets done
                            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Data mismatch detected. Throwing error.";

                            RETURN_CODE=70;
                        else
                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "File and zone lists agree. Continuing..";

                            ## make sure d is zero
                            D=0;
                            ERROR_COUNTER=0;

                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Creating working copy of decom config file..";

                            ## take a copy of the decom conf file and operate on it
                            ## theres no decom conf file to copy from, so touch create what we need
                            touch "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";

                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Creation complete. Verifying..";

                            ## make sure its there..
                            if [ -f "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}" ]
                            then
                                ## it is. good.
                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Creation complete. Proceeding..";

                                while [ ${D} -ne ${#ZONE_LISTING[*]} ]
                                do
                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Adding configuration entry for ${ZONE_LISTING[${D}]}";

                                    ## add the entry...
                                    echo "zone \"${ZONE_LISTING[${D}]}\" IN {" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                                    echo "    type              master;" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                                    echo "    file              \"${FILE_LISTING[${D}]}\";" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                                    echo "    allow-update      { none; };" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                                    echo "    allow-transfer    { key ${TSIG_TRANSFER_KEY}; };" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                                    echo "};\n" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";

                                    ## confirm the entry..
                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Entry added. Confirming..";

                                    ## ok, so it should be in there now. verify -
                                    if [ $(grep -c "zone \"${ZONE_LISTING[${D}]}\" IN {" "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}") -eq 1 ]
                                    then
                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Added ${ZONE_LISTING[${D}]} to the decom config file.";
                                    else
                                        ## entry did not get added. hmm.
                                        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to add configuration for ${ZONE_LISTING[${D}]} to the decom config file.";

                                        (( ERROR_COUNTER += 1 ));
                                    fi

                                    (( D += 1 ));
                                done

                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Completed zone processing. Verifying..";

                                ## ok, processing is complete. check the error counter and make sure its zero.
                                if [ ${ERROR_COUNTER} -eq 0 ]
                                then
                                    ## successfully modified our decom conf file, and it contains all the data it should have.
                                    ## now we copy our decom conf file into place...
                                    cp "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}" "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}";

                                    ## copy complete. lets make sure they match..
                                    OP_CHECKSUM=$(cksum "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" | awk '{print $1}');
                                    TMP_CHECKSUM=$(cksum "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}" | awk '{print $1}');

                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OP_CHECKSUM -> ${OP_CHECKSUM}";
                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "TMP_CHECKSUM -> ${TMP_CHECKSUM}";

                                    ## we have our checksums, match them.
                                    if [ ${OP_CHECKSUM} -ne ${TMP_CHECKSUM} ]
                                    then
                                        ## they do not match. this means something broke.
                                        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to properly copy the decom configuration file. Unable to continue.";

                                        RETURN_CODE=70;
                                    else
                                        ## ok, we've gotten the new data into the installation.
                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Checksums match. Continuing..";

                                        ## its time to move the files.
                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Moving business unit zone directory..";

                                        ## make sure the decom dir exists.. if not, create it
                                        [ ! -d "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR} ] && mkdir "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR};

                                        mv "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${BUSINESS_UNIT} "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT};

                                        ## and make sure it got moved.
                                        if [ -d "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT} ]
                                        then
                                            ## ok, cool. we can keep going
                                            ## we can now remove the bu conf file, and copy our temporary decom conf file into place
                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Removing business unit config file..";

                                            rm -rf "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME};

                                            ## and make sure its gone...
                                            if [ ! -s "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} ] &&
                                                [ ! -f "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} ]
                                            then
                                                ## it is. lets remove it from the named.conf file and add in (if necessary)
                                                ## the decom conf file.
                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Removal complete. Backing up primary configuration..";

                                                ## back it up..
                                                cp ${NAMED_CONF_FILE} "${PLUGIN_BACKUP_DIR}"/${CONF_FILE}.${CHANGE_NUM};

                                                ## and confirm..
                                                if [ -s "${PLUGIN_BACKUP_DIR}"/${CONF_FILE}.${CHANGE_NUM} ]
                                                then
                                                    ## backup complete. operate.
                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backup complete. Creating working copy of named configuration..";

                                                    ## create copy of named conf file..
                                                    cp ${NAMED_CONF_FILE} "${PLUGIN_TMP_DIRECTORY}"/${CONF_FILE}.${CHANGE_NUM};

                                                    ## and make sure it happened..
                                                    if [ -s "${PLUGIN_TMP_DIRECTORY}"/${CONF_FILE}.${CHANGE_NUM} ]
                                                    then
                                                        ## good. lets keep going
                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Working copy created. Operating..";
                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Removing entry from ${NAMED_CONF_FILE}..";

                                                        if [ $(grep -c "${DECOM_CONF_FILE}" "${PLUGIN_TMP_DIRECTORY}"/${CONF_FILE}.${CHANGE_NUM}) -eq 0 ]
                                                        then
                                                            ## its not there, so lets replace the existing business unit filename
                                                            ## with the decom filename
                                                            sed -e "s^/"${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}^/"${NAMED_CONF_DIR}/${DECOM_CONF_FILE}"^" \
                                                                "${PLUGIN_WORK_DIRECTORY}"/${CONF_FILE}.${CHANGE_NUM} > "${PLUGIN_TMP_DIRECTORY}"/${CONF_FILE}.${CHANGE_NUM};
                                                        else
                                                            ## its already there, so just remove the entry
                                                            sed -e "/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}/d" \
                                                                "${PLUGIN_WORK_DIRECTORY}"/${CONF_FILE}.${CHANGE_NUM} > "${PLUGIN_TMP_DIRECTORY}"/${CONF_FILE}.${CHANGE_NUM};
                                                        fi

                                                        ## move the file back to where it was before..
                                                        mv "${PLUGIN_TMP_DIRECTORY}"/${CONF_FILE}.${CHANGE_NUM} "${PLUGIN_WORK_DIRECTORY}"/${CONF_FILE}.${CHANGE_NUM};

                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Entry removed. Validating..";

                                                        ## and make sure it was removed..
                                                        if [ $(grep -c ${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} "${PLUGIN_WORK_DIRECTORY}"/${CONF_FILE}.${CHANGE_NUM}) -eq 0 ]
                                                        then
                                                            ## we should be done here. make sure our decom include is in, and if so, copy the file
                                                            if [ $(grep -c "${DECOM_CONF_FILE}" "${PLUGIN_TMP_DIRECTORY}"/${CONF_FILE}.${CHANGE_NUM}) -ne 0 ]
                                                            then
                                                                ## its there. lets move.
                                                                cp "${PLUGIN_TMP_DIRECTORY}"/${CONF_FILE}.${CHANGE_NUM} ${NAMED_CONF_FILE};

                                                                ## and checksum...
                                                                TMP_CONF_CKSUM=$(cksum "${PLUGIN_TMP_DIRECTORY}"/${CONF_FILE}.${CHANGE_NUM} | awk '{print $1}');
                                                                OP_CONF_CKSUM=$(cksum ${NAMED_CONF_FILE} | awk '{print $1}');

                                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "TMP_CONF_CKSUM -> ${TMP_CONF_CKSUM}";
                                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OP_CONF_CKSUM -> ${OP_CONF_CKSUM}";

                                                                ## and validate...
                                                                if [ ${TMP_CONF_CKSUM} -eq ${OP_CONF_CKSUM} ]
                                                                then
                                                                    ## ok, checksums match, we're super.
                                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Decommission of ${ZONE_NAME} from "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} complete.";
                                                                    writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone ${ZONE_NAME} decommissioned by ${REQUESTING_USER} per change ${CHANGE_NUM} on $(date +"%m-%d-%Y") at $(date +"%H:%M:%S")";

                                                                    RETURN_CODE=0;
                                                                else
                                                                    ## ok, so our checksums dont match. this probably means that the named conf in tmp/ didnt
                                                                    ## copy to where its supposed to go. this *should* be ok, but does warrant some review. writeLogEntry "AUDIT" "${METHOD_NAME}".
                                                                    writeLogEntry writeLogEntry "AUDIT" "${METHOD_NAME}" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CHECKSUM MISMATCH: Failed to validate that named configuration file was updated.";

                                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Decommission of ${ZONE_NAME} from "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} complete.";
                                                                    writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone ${ZONE_NAME} decommissioned by ${REQUESTING_USER} per change ${CHANGE_NUM} on $(date +"%m-%d-%Y") at $(date +"%H:%M:%S")";

                                                                    RETURN_CODE=72;
                                                                fi
                                                            else
                                                                ## failed to pipe in the decom include. error
                                                                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to include the decom configuration information in the master configuration file. Unable to proceed.";
                                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                                                RETURN_CODE=72;
                                                            fi
                                                        else
                                                            ## include statement didnt get removed. this will result in named errors. fail.
                                                            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to backup the primary configuration file. Cannot continue.";
                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                                            RETURN_CODE=70;
                                                        fi
                                                    else
                                                        ## couldnt create a copy. fail.
                                                        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to backup the primary configuration file. Cannot continue.";
                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                                        RETURN_CODE=47;
                                                    fi
                                                else
                                                    ## couldnt backup named config. fail
                                                    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to backup the primary configuration file. Cannot continue.";
                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                                    RETURN_CODE=57;
                                                fi
                                            else
                                                ## failed to remove bu conf file. writeLogEntry "AUDIT" "${METHOD_NAME}", but dont fail.
                                                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to remove the business unit configuration file.";
                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                                RETURN_CODE=70;
                                            fi
                                        else
                                            ## failed to relocate zone files. throw an error
                                            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to relocate zone files for business unit.";
                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                            RETURN_CODE=70;
                                        fi
                                    fi
                                else
                                    ## our error counter is not zero. this means something didnt get added.
                                    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "One or more zone entries did not add properly. Unable to continue.";
                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                    RETURN_CODE=70;
                                fi
                            else
                                ## we wont operate on the hot copy. not for this kind of work.
                                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to create a working copy of "${DECOM_CONF_FILE}". Unable to continue.";
                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                RETURN_CODE=47;
                            fi
                        fi
                    else
                        ## hmm. one or both of our variables is blank. hmm. fail it, we dont have the necessary information to proceed
                        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Necessary data to proceed with the operation was not found. Please try again.";
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                        RETURN_CODE=28;
                    fi
                fi
            else
                ## failed to take a bu conf backup. error.
                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to create business unit configuration backup. Cannot continue.";
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                RETURN_CODE-57;
            fi
        else
            ## failed to take a bu zone backup. error.
            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to create zone configuration backup. Cannot continue.";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

            RETURN_CODE=57;
        fi
    else
        ## we were provided information necessary to perform the work, but the information given doesnt map to
        ## actual files/directories on the filesystem. cant operate with nothing to operate against
        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to create zone configuration backup. Cannot continue.";
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

        RETURN_CODE=10;
    fi

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

    ## remove any tmp files
    rm -rf "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
    rm -rf "${PLUGIN_TMP_DIRECTORY}"/${CONF_FILE}.${CHANGE_NUM};

    unset END_LINE_NUMBER;
    unset START_LINE_NUMBER;
    unset ZONEFILE_NAME;
    unset CONF_TMP_CKSUM;
    unset CONF_OP_CKSUM;
    unset TMP_CONF_CKSUM;
    unset OP_CONF_CKSUM;
    unset CHANGE_DATE;
    unset CHANGE_NUM;

    [ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "true" ] && set +x;
    [ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set +x;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +v;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +v;

    return ${RETURN_CODE};
}

#===  FUNCTION  ===============================================================
#          NAME:  decom_master_zone
#   DESCRIPTION:  Searches for and replaces audit indicators for the provided
#                 filename.
#    PARAMETERS:  Parameters obtained via command-line flags
#          NAME:  usage for positive result, >1 for non-positive
#==============================================================================
function decom_master_zone
{
[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "true" ] && set -x;
[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set -x;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -v;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -v;
    typeset METHOD_NAME="${CNAME}#${0}";
    typeset RETURN_CODE=0;

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Provided arguments: ${*}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Performing decommission of ${ZONE_NAME}";

    ## set up our zonefile name
    typeset CHANGE_DATE=$(date +"%m-%d-%Y");
    typeset ZONEFILE_NAME=${NAMED_ZONE_PREFIX}.$(cut -d "." -f 1 <<< ${ZONE_NAME}).${PROJECT_CODE};
    typeset SHORT_ZONEFILE_NAME=$(cut -d "." -f 1-2 <<< ${ZONEFILE_NAME});
    typeset TARFILE_NAME=${GROUP_ID}${BUSINESS_UNIT}.${CHANGE_NUM}.${CHANGE_DATE}.${REQUESTING_USER};
    typeset LC_BUSINESS_UNIT=$(tr "[A-Z]" "[a-z]" <<< ${BUSINESS_UNIT});
    typeset CUT_ZONE=$(cut -d "." -f 1 <<< ${ZONE_NAME});
    typeset CONF_FILE=$(cut -d "/" -f 5 <<< ${NAMED_CONF_FILE});

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "ZONEFILE_NAME -> ${ZONEFILE_NAME}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "SHORT_ZONEFILE_NAME -> ${SHORT_ZONEFILE_NAME}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "TARFILE_NAME -> ${TARFILE_NAME}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Validating that requested directories/files exist..";

    ## need to make sure the provided information actually exists in the install
    if [ -d "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${BUSINESS_UNIT} ] &&
        [ -s "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${BUSINESS_UNIT}/${ZONEFILE_NAME} ] &&
        [ -s "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${BUSINESS_UNIT}/${PRIMARY_DC}/${SHORT_ZONEFILE_NAME} ] &&
        [ -s "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${BUSINESS_UNIT}/${SECONDARY_DC}/${SHORT_ZONEFILE_NAME} ]
    then
        ## take our backups
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backing up files..";

        ## take backups
        tar cf "${PLUGIN_BACKUP_DIR}"/${TARFILE_NAME}.tar -C "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT} \
            ${GROUP_ID}${BUSINESS_UNIT}/${NAMED_ZONE_PREFIX}.${CUT_ZONE}.${PROJECT_CODE} \
            ${GROUP_ID}${BUSINESS_UNIT}/${PRIMARY_DC}/${NAMED_ZONE_PREFIX}.${CUT_ZONE} \
            ${GROUP_ID}${BUSINESS_UNIT}/${SECONDARY_DC}/${NAMED_ZONE_PREFIX}.${CUT_ZONE} >> /dev/null 2>&1;
        gzip "${PLUGIN_BACKUP_DIR}"/${TARFILE_NAME}.tar >> /dev/null 2>&1;

        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backup complete. Verifying..";

        ## make sure the backup tarball exists. if it doesnt, dont continue
        if [ -s "${PLUGIN_BACKUP_DIR}"/${TARFILE_NAME}.tar.gz ]
        then
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backup verified. Continuing..";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Checking for ${GROUP_ID}${NAMED_DECOM_DIR}..";

            ## make sure our decom folder exists, if not, create it
            [ ! -d "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR} ] && mkdir "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR};

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Checking for ${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT}..";

            ## check if a directory already exists for our biz unit, if not, create it
            if [ ! -d "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT} ]
            then
                mkdir "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT};
                mkdir "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT}/${PRIMARY_DC};
                mkdir "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT}/${SECONDARY_DC};
            fi

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Pre-work and verification complete.";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Moving zone files..";

            ## ok, so we've done the necessary pre-work. now we move the files into the decom dir
            mv "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${BUSINESS_UNIT}/${ZONEFILE_NAME} \
                "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT}/${ZONEFILE_NAME};
            mv "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${BUSINESS_UNIT}/${PRIMARY_DC}/$(cut -d "." -f 1-2 <<< ${ZONEFILE_NAME}) \
                "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT}/${PRIMARY_DC}/$(cut -d "." -f 1-2 <<< ${ZONEFILE_NAME});
            mv "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${BUSINESS_UNIT}/${SECONDARY_DC}/$(cut -d "." -f 1-2 <<< ${ZONEFILE_NAME}) \
                "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT}/${SECONDARY_DC}/$(cut -d "." -f 1-2 <<< ${ZONEFILE_NAME});

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Move complete. Verifying..";

            ## ok, so now the files should no longer exist in their usual locations and should exist in the decom dir.
            ## lets check
            if [ -s "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT}/${ZONEFILE_NAME} ] &&
                [ -s "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT}/${PRIMARY_DC}/$(cut -d "." -f 1-2 <<< ${ZONEFILE_NAME}) ] &&
                [ -s "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT}/${SECONDARY_DC}/$(cut -d "." -f 1-2 <<< ${ZONEFILE_NAME}) ]
            then
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Move verified. Verifying file removal..";

                ## ok, we know theyre in the decom dir. make sure they arent in their usual location
                if [ ! -s "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${BUSINESS_UNIT}/${ZONEFILE_NAME} ] &&
                    [ ! -s "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${BUSINESS_UNIT}/${PRIMARY_DC}/$(cut -d "." -f 1-2 <<< ${ZONEFILE_NAME}) ] &&
                    [ ! -s "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${BUSINESS_UNIT}/${SECONDARY_DC}/$(cut -d "." -f 1-2 <<< ${ZONEFILE_NAME}) ]
                then
                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Checking if any remaining files exist..";

                    ## check if theres anything left
                    if [ $(find "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${BUSINESS_UNIT} -type f -echo | wc -l) -eq 0 ]
                    then
                        ## ok, we didnt find any files, so we can remove the directory
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No files found, removing..";

                        rm -rf "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${BUSINESS_UNIT};
                    fi

                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Move verified successful. Adding entry to "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}"..";

                    ## first, create a working copy
                    if [ -s "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" ] || [ -f "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" ]
                    then
                        ## it exists.. back it up and take a copy
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backing up "${DECOM_CONF_FILE}"..";

                        cp "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" "${PLUGIN_BACKUP_DIR}/${DECOM_CONF_FILE}".${CHANGE_NUM};

                        if [ -s "${PLUGIN_BACKUP_DIR}/${DECOM_CONF_FILE}".${CHANGE_NUM} ]
                        then
                            ## good, we have a valid backup. move forward
                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Creating working copy of "${DECOM_CONF_FILE}"..";

                            cp "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";

                            if [ -s "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}" ] || [ -s "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}" ]
                            then
                                ## excellent! now we can remove it from the biz unit conf file and pipe a new entry into the decom conf file
                                ## first, add it to the decom conf file
                                echo "zone \"${ZONE_NAME}\" IN {" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                                echo "    type              slave;" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                                echo "    file              \"${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT}/${ZONEFILE_NAME}\";" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                                echo "    allow-update      { none; };" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                                echo "    allow-transfer    { key ${TSIG_TRANSFER_KEY}; };" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                                echo "};\n" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";

                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Entry added. Confirming..";

                                ## ok, so it should be in there now. verify -
                                if [ -s "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}" ] &&
                                    [ $(grep -c "zone \"${ZONE_NAME}\" IN {" "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}") -eq 1 ]
                                then
                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Copying decom config file into installation..";

                                    DECOM_TMP_CKSUM=$(cksum "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}" | awk '{print $1}');

                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "DECOM_TMP_CKSUM -> ${DECOM_TMP_CKSUM}";

                                    ## great. now we can move the updated decom conf file into the installation
                                    mv "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}" "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}";

                                    ## ok. file copied. make sure
                                    DECOM_OP_CKSUM=$(cksum "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" | awk '{print $1}');

                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "DECOM_OP_CKSUM -> ${DECOM_OP_CKSUM}";

                                    if [ ${DECOM_OP_CKSUM} != ${DECOM_TMP_CKSUM} ]
                                    then
                                        ## the file copy appears to have failed. throw an error
                                        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to match checksums of decom config files. Unable to continue.";
                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                        RETURN_CODE=70;
                                    else
                                        ## file exists and entry has been added. now we can remove it from the file it originally belonged to
                                        ## make sure said file exists...
                                        if [ -s "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} ]
                                        then
                                            ## it does. take a backup..
                                            cp "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} \
                                                "${PLUGIN_BACKUP_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}.${CHANGE_NUM};

                                            if [ -s "${PLUGIN_BACKUP_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}.${CHANGE_NUM} ]
                                            then
                                                ## backup complete.
                                                ## remove entry. get the line numbers we need
                                                START_LINE_NUMBER=$(sed -n "/zone \"${ZONE_NAME}\" IN {/=" "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME});
                                                END_LINE_NUMBER=$(expr ${START_LINE_NUMBER} + 6);

                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "START_LINE_NUMBER -> ${START_LINE_NUMBER}";
                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "END_LINE_NUMBER -> ${END_LINE_NUMBER}";

                                                sed -e "${START_LINE_NUMBER},${END_LINE_NUMBER} d" "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} \
                                                    >> "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME};

                                                ## ok, should now be removed from the tmp file we've created. validate.
                                                if [ $(grep -c "zone \"${ZONE_NAME}\" IN {" "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}) -eq 0 ]
                                                then
                                                    ## lets see if the file is now empty. if it is, just delete it. we dont need it anymore.
                                                    if [ ! -s "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} ]
                                                    then
                                                        ## it is. remove it and its associated entry in named.conf
                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Validated entry removal. File has been cleared of content. Removing..";
                                                        rm -rf "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME};
                                                        rm -rf "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME};

                                                        unset START_LINE_NUMBER;
                                                        unset END_LINE_NUMBER;

                                                        ## back it up
                                                        cp ${NAMED_CONF_FILE} "${PLUGIN_BACKUP_DIR}"/${CONF_FILE}.${CHANGE_NUM};

                                                        START_LINE_NUMBER=$(sed -n "/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}/=" ${NAMED_CONF_FILE});

                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Removing entry from ${NAMED_CONF_FILE}..";

                                                        ## files removed, remove the entry in named.conf
                                                        sed -e "${START_LINE_NUMBER} d" ${NAMED_CONF_FILE} >> "${PLUGIN_TMP_DIRECTORY}"/named.conf;

                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Entry removed. Validating..";

                                                        ## ok should be gone. lets make sure.
                                                        if [ $(grep -c "${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}" "${PLUGIN_TMP_DIRECTORY}"/named.conf) -eq 0 ]
                                                        then
                                                            ## entry successfully removed. make it the normal copy.
                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Confirmed removal. Copying..";

                                                            TMP_CONF_CKSUM=$(cksum "${PLUGIN_TMP_DIRECTORY}"/named.conf | awk '{print $1}');

                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "TMP_CONF_CKSUM -> ${TMP_CONF_CKSUM}";

                                                            mv "${PLUGIN_TMP_DIRECTORY}"/named.conf ${NAMED_CONF_FILE};

                                                            ## and checksum...
                                                            OP_CONF_CKSUM=$(cksum ${NAMED_CONF_FILE} | awk '{print $1}');

                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OP_CONF_CKSUM -> ${OP_CONF_CKSUM}";

                                                            ## and validate...
                                                            if [ ${TMP_CONF_CKSUM} -eq ${OP_CONF_CKSUM} ]
                                                            then
                                                                ## check for an entry in named.conf for the decom config file. if its not
                                                                ## there then add it
                                                                if [ $(grep -c "${DECOM_CONF_FILE}" ${NAMED_CONF_FILE}) -eq 0 ]
                                                                then
                                                                    ## its not there, lets add it
                                                                    echo "include \"/"${NAMED_CONF_DIR}/${DECOM_CONF_FILE}"\";" >> ${NAMED_CONF_FILE};
                                                                fi

                                                                ## ok, checksums match, we're super.
                                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Decommission of ${ZONE_NAME} from "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} complete.";
                                                                writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone ${ZONE_NAME} decommissioned by ${REQUESTING_USER} per change ${CHANGE_NUM} on $(date +"%m-%d-%Y") at $(date +"%H:%M:%S")";

                                                                RETURN_CODE=0;
                                                            else
                                                                ## ok, so our checksums dont match. this probably means that the named conf in tmp/ didnt
                                                                ## copy to where its supposed to go. this *should* be ok, but does warrant some review. writeLogEntry "AUDIT" "${METHOD_NAME}".
                                                                writeLogEntry writeLogEntry "AUDIT" "${METHOD_NAME}" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CHECKSUM MISMATCH: Failed to validate that named configuration file was updated.";

                                                                if [ $(grep -c "${DECOM_CONF_FILE}" ${NAMED_CONF_FILE}) -eq 0 ]
                                                                then
                                                                    ## its not there, lets add it
                                                                    echo "include \"/"${NAMED_CONF_DIR}/${DECOM_CONF_FILE}"\";" >> ${NAMED_CONF_FILE};
                                                                fi

                                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Decommission of ${ZONE_NAME} from "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} complete.";
                                                                writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone ${ZONE_NAME} decommissioned by ${REQUESTING_USER} per change ${CHANGE_NUM} on $(date +"%m-%d-%Y") at $(date +"%H:%M:%S")";

                                                                RETURN_CODE=72;
                                                            fi
                                                        else
                                                            ## failed to remove entry from the named config file. we care, but not enough to fail the entire
                                                            ## process, as named will continue chugging along with an empty file. writeLogEntry "AUDIT" "${METHOD_NAME}".
                                                            writeLogEntry writeLogEntry "AUDIT" "${METHOD_NAME}" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to remove zone include statement from named configuration file.";

                                                            ## check for an entry in named.conf for the decom config file. if its not
                                                            ## there then add it
                                                            if [ $(grep -c "${DECOM_CONF_FILE}" ${NAMED_CONF_FILE}) -eq 0 ]
                                                            then
                                                                ## its not there, lets add it
                                                                echo "include \"/"${NAMED_CONF_DIR}/${DECOM_CONF_FILE}"\";" >> ${NAMED_CONF_FILE};
                                                            fi

                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Decommission of ${ZONE_NAME} from "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} complete.";
                                                            writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone ${ZONE_NAME} decommissioned by ${REQUESTING_USER} per change ${CHANGE_NUM} on $(date +"%m-%d-%Y") at $(date +"%H:%M:%S")";

                                                            RETURN_CODE=72;
                                                        fi
                                                    else
                                                        ## verified removal. lets make this file the active file and call it a day.
                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Moving "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} to "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}..";

                                                        ## checksum tmp file
                                                        CONF_TMP_CKSUM=$(cksum "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} | awk '{print $1}');

                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CONF_TMP_CKSUM -> ${CONF_TMP_CKSUM}";

                                                        mv "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} \
                                                            "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME};

                                                        ## checksum operational
                                                        CONF_OP_CKSUM=$(cksum "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} | awk '{print $1}');

                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CONF_OP_CKSUM -> ${CONF_OP_CKSUM}";

                                                        if [ ${CONF_TMP_CKSUM} -eq ${CONF_OP_CKSUM} ]
                                                        then
                                                            ## check for an entry in named.conf for the decom config file. if its not
                                                            ## there then add it
                                                            if [ $(grep -c "${DECOM_CONF_FILE}" ${NAMED_CONF_FILE}) -eq 0 ]
                                                            then
                                                                ## its not there, lets add it
                                                                echo "include \"/"${NAMED_CONF_DIR}/${DECOM_CONF_FILE}"\";" >> ${NAMED_CONF_FILE};
                                                            fi

                                                            ## we're done here.
                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Removal of ${ZONE_NAME} from "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} complete.";
                                                            writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone ${ZONE_NAME} decommissioned by ${REQUESTING_USER} per change ${CHANGE_NUM} on $(date +"%m-%d-%Y") at $(date +"%H:%M:%S")";

                                                            RETURN_CODE=0;
                                                        else
                                                            ## checksums dont match. this probably means that the file didnt move into place properly.
                                                            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Checksum mismatch against business unit configuration file. Validation failed.";

                                                            RETURN_CODE=70;
                                                        fi
                                                    fi
                                                else
                                                    ## removal of the zone from the biz conf file didn't work for some reason. return an error
                                                    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to validate that zone has been removed from the business unit configuration.";

                                                    RETURN_CODE=70;
                                                fi
                                            else
                                                ## couldnt create the backup file
                                                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to create configuration backup. Cannot continue.";
                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                                RETURN_CODE=57;
                                            fi
                                        else
                                            ## biz conf file doesnt exist ?!
                                            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Business Unit configuration file does not exist. Please verify that the zone name provided is accurate.";

                                            RETURN_CODE=14;
                                        fi
                                    fi
                                else
                                    ## decom file failed to update with new zone
                                    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to update "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" with the new configuration.";

                                    RETURN_CODE=70;
                                fi
                            else
                                ## we were unable to create a copy of the decom conf file. fail.
                                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to update "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" with the new configuration.";

                                RETURN_CODE=70;
                            fi
                        else
                            ## we have no backup. we can't keep going.
                            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to update "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" with the new configuration.";

                            RETURN_CODE=70;
                        fi
                    else
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Found no decom conf file. Creating a new one..";

                        touch "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";

                        if [ -f "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}" ]
                        then
                            ## excellent! now we can remove it from the biz unit conf file and pipe a new entry into the decom conf file
                            ## first, add it to the decom conf file
                            echo "zone \"${ZONE_NAME}\" IN {" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                            echo "    type              slave;" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                            echo "    file              \"${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT}/${ZONEFILE_NAME}\";" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                            echo "    allow-update      { none; };" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                            echo "    allow-transfer    { key ${TSIG_TRANSFER_KEY}; };" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                            echo "};\n" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";

                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Entry added. Confirming..";

                            ## ok, so it should be in there now. verify -
                            if [ $(grep -c "zone \"${ZONE_NAME}\" IN {" "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}") -eq 1 ]
                            then
                                ## great. now we can move the updated decom conf file into the installation
                                cp "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}" "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}";

                                ## ok. file copied. make sure
                                DECOM_TMP_CKSUM=$(cksum "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}" | awk '{print $1}');
                                DECOM_OP_CKSUM=$(cksum "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" | awk '{print $1}');

                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "DECOM_TMP_CKSUM -> ${DECOM_TMP_CKSUM}";
                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "DECOM_OP_CKSUM -> ${DECOM_OP_CKSUM}";

                                if [ ${DECOM_OP_CKSUM} != ${DECOM_TMP_CKSUM} ]
                                then
                                    ## the file copy appears to have failed. throw an error
                                    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to match checksums of decom config files. Unable to continue.";
                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                    RETURN_CODE=70;
                                else
                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Confirmation complete. Removing entry from "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME})..";

                                    ## file exists and entry has been added. now we can remove it from the file it originally belonged to
                                    ## make sure said file exists...
                                    if [ -s "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} ]
                                    then
                                        ## it does. take a backup..
                                        cp "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} \
                                            "${PLUGIN_BACKUP_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}.${CHANGE_NUM};

                                        if [ -s "${PLUGIN_BACKUP_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}.${CHANGE_NUM} ]
                                        then
                                            ## backup complete.
                                            ## remove entry. get the line numbers we need
                                            START_LINE_NUMBER=$(sed -n "/zone \"${ZONE_NAME}\" IN {/=" "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME});
                                            END_LINE_NUMBER=$(expr ${START_LINE_NUMBER} + 6);

                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "START_LINE_NUMBER -> ${START_LINE_NUMBER}";
                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "END_LINE_NUMBER -> ${END_LINE_NUMBER}";

                                            sed -e "${START_LINE_NUMBER},${END_LINE_NUMBER} d" "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} \
                                                >> "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME};

                                            ## ok, should now be removed from the tmp file we've created. validate.
                                            if [ $(grep -c "zone \"${ZONE_NAME}\" IN {" "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}) -eq 0 ]
                                            then
                                                ## lets see if the file is now empty. if it is, just delete it. we dont need it anymore.
                                                if [ ! -s "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} ]
                                                then
                                                    ## it is. remove it and its associated entry in named.conf
                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Validated entry removal. File has been cleared of content. Removing..";
                                                    rm -rf "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME};
                                                    rm -rf "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME};

                                                    unset START_LINE_NUMBER;
                                                    unset END_LINE_NUMBER;

                                                    ## back it up
                                                    cp ${NAMED_CONF_FILE} "${PLUGIN_BACKUP_DIR}"/${CONF_FILE}.${CHANGE_NUM};

                                                    START_LINE_NUMBER=$(sed -n "/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}/=" ${NAMED_CONF_FILE});

                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Removing entry from ${NAMED_CONF_FILE}..";

                                                    ## files removed, remove the entry in named.conf
                                                    sed -e "${START_LINE_NUMBER} d" ${NAMED_CONF_FILE} >> "${PLUGIN_TMP_DIRECTORY}"/named.conf;

                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Entry removed. Validating..";

                                                    ## ok should be gone. lets make sure.
                                                    if [ $(grep -c "${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}" "${PLUGIN_TMP_DIRECTORY}"/named.conf) -eq 0 ]
                                                    then
                                                        ## entry successfully removed. make it the normal copy.
                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Confirmed removal. Copying..";

                                                        cp "${PLUGIN_TMP_DIRECTORY}"/named.conf ${NAMED_CONF_FILE};

                                                        ## and checksum...
                                                        TMP_CONF_CKSUM=$(cksum "${PLUGIN_TMP_DIRECTORY}"/named.conf | awk '{print $1}');
                                                        OP_CONF_CKSUM=$(cksum ${NAMED_CONF_FILE} | awk '{print $1}');

                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "TMP_CONF_CKSUM -> ${TMP_CONF_CKSUM}";
                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OP_CONF_CKSUM -> ${OP_CONF_CKSUM}";

                                                        ## and validate...
                                                        if [ ${TMP_CONF_CKSUM} -eq ${OP_CONF_CKSUM} ]
                                                        then
                                                            ## check for an entry in named.conf for the decom config file. if its not
                                                            ## there then add it
                                                            if [ $(grep -c "${DECOM_CONF_FILE}" ${NAMED_CONF_FILE}) -eq 0 ]
                                                            then
                                                                ## its not there, lets add it
                                                                echo "include \"/"${NAMED_CONF_DIR}/${DECOM_CONF_FILE}"\";" >> ${NAMED_CONF_FILE};
                                                            fi

                                                            ## ok, checksums match, we're super.
                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Decommission of ${ZONE_NAME} from "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} complete.";
                                                            writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone ${ZONE_NAME} decommissioned by ${REQUESTING_USER} per change ${CHANGE_NUM} on $(date +"%m-%d-%Y") at $(date +"%H:%M:%S")";

                                                            RETURN_CODE=0;
                                                        else
                                                            ## ok, so our checksums dont match. this probably means that the named conf in tmp/ didnt
                                                            ## copy to where its supposed to go. this *should* be ok, but does warrant some review. writeLogEntry "AUDIT" "${METHOD_NAME}".
                                                            writeLogEntry writeLogEntry "AUDIT" "${METHOD_NAME}" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CHECKSUM MISMATCH: Failed to validate that named configuration file was updated.";

                                                            if [ $(grep -c "${DECOM_CONF_FILE}" ${NAMED_CONF_FILE}) -eq 0 ]
                                                            then
                                                                ## its not there, lets add it
                                                                echo "include \"/"${NAMED_CONF_DIR}/${DECOM_CONF_FILE}"\";" >> ${NAMED_CONF_FILE};
                                                            fi

                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Decommission of ${ZONE_NAME} from "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} complete.";
                                                            writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone ${ZONE_NAME} decommissioned by ${REQUESTING_USER} per change ${CHANGE_NUM} on $(date +"%m-%d-%Y") at $(date +"%H:%M:%S")";

                                                            RETURN_CODE=72;
                                                        fi
                                                    else
                                                        ## failed to remove entry from the named config file. we care, but not enough to fail the entire
                                                        ## process, as named will continue chugging along with an empty file. writeLogEntry "AUDIT" "${METHOD_NAME}".
                                                        writeLogEntry writeLogEntry "AUDIT" "${METHOD_NAME}" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to remove zone include statement from named configuration file.";

                                                        ## check for an entry in named.conf for the decom config file. if its not
                                                        ## there then add it
                                                        if [ $(grep -c "${DECOM_CONF_FILE}" ${NAMED_CONF_FILE}) -eq 0 ]
                                                        then
                                                            ## its not there, lets add it
                                                            echo "include \"/"${NAMED_CONF_DIR}/${DECOM_CONF_FILE}"\";" >> ${NAMED_CONF_FILE};
                                                        fi

                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Decommission of ${ZONE_NAME} from "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} complete.";
                                                        writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone ${ZONE_NAME} decommissioned by ${REQUESTING_USER} per change ${CHANGE_NUM} on $(date +"%m-%d-%Y") at $(date +"%H:%M:%S")";

                                                        RETURN_CODE=72;
                                                    fi
                                                else
                                                    ## verified removal. lets make this file the active file and call it a day.
                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Moving "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} to "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}..";

                                                    ## checksum tmp file
                                                    CONF_TMP_CKSUM=$(cksum "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} | awk '{print $1}');

                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CONF_TMP_CKSUM -> ${CONF_TMP_CKSUM}";

                                                    mv "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} \
                                                        "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME};

                                                    ## checksum operational
                                                    CONF_OP_CKSUM=$(cksum "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} | awk '{print $1}');

                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CONF_OP_CKSUM -> ${CONF_OP_CKSUM}";

                                                    if [ ${CONF_TMP_CKSUM} -eq ${CONF_OP_CKSUM} ]
                                                    then
                                                        ## check for an entry in named.conf for the decom config file. if its not
                                                        ## there then add it
                                                        if [ $(grep -c "${DECOM_CONF_FILE}" ${NAMED_CONF_FILE}) -eq 0 ]
                                                        then
                                                            ## its not there, lets add it
                                                            echo "include \"/"${NAMED_CONF_DIR}/${DECOM_CONF_FILE}"\";" >> ${NAMED_CONF_FILE};
                                                        fi

                                                        ## we're done here.
                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Removal of ${ZONE_NAME} from "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} complete.";
                                                        writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone ${ZONE_NAME} decommissioned by ${REQUESTING_USER} per change ${CHANGE_NUM} on $(date +"%m-%d-%Y") at $(date +"%H:%M:%S")";

                                                        RETURN_CODE=0;
                                                    else
                                                        ## checksums dont match. this probably means that the file didnt move into place properly.
                                                        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Checksum mismatch against business unit configuration file. Validation failed.";

                                                        RETURN_CODE=70;
                                                    fi
                                                fi
                                            else
                                                ## removal of the zone from the biz conf file didn't work for some reason. return an error
                                                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to validate that zone has been removed from the business unit configuration.";

                                                RETURN_CODE=70;
                                            fi
                                        else
                                            ## couldnt create the backup file
                                            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to create configuration backup. Cannot continue.";
                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                            RETURN_CODE=57;
                                        fi
                                    else
                                        ## biz conf file doesnt exist ?!
                                        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Business Unit configuration file does not exist. Please verify that the zone name provided is accurate.";

                                        RETURN_CODE=14;
                                    fi
                                fi
                            else
                                ## decom file failed to update with new zone
                                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to update "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" with the new configuration.";

                                RETURN_CODE=70;
                            fi
                        else
                            ## we were unable to create a copy of the decom conf file. fail.
                            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to update "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" with the new configuration.";

                            RETURN_CODE=70;
                        fi
                    fi
                else
                    ## move failed. really this should be a warning, but we're going to
                    ## fail because it makes more sense to fail and investigate the issue
                    ## than it does to leave the files in place and just keep going
                    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to move files from Business Unit directory to ${NAMED_DECOM_DIR}.";

                    RETURN_CODE=70;
                fi
            else
                ## move failed. really this should be a warning, but we're going to
                ## fail because it makes more sense to fail and investigate the issue
                ## than it does to leave the files in place and just keep going
                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to move files from Business Unit directory to ${NAMED_DECOM_DIR}.";

                RETURN_CODE=70;
            fi
        else
            ## failed to create a backup of the existing configuration
            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to create zone configuration backup. Cannot continue.";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

            RETURN_CODE=57;
        fi
    else
        ## we were provided information necessary to perform the work, but the information given doesnt map to
        ## actual files/directories on the filesystem. cant operate with nothing to operate against
        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to locate the necessary directories. Cannot continue.";
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

        RETURN_CODE=12;
    fi

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

    ## remove any tmp files
    [ -f "${PLUGIN_TMP_DIRECTORY}"/named.conf ] && rm -rf "${PLUGIN_TMP_DIRECTORY}"/named.conf;

    unset END_LINE_NUMBER;
    unset START_LINE_NUMBER;
    unset ZONEFILE_NAME;
    unset CONF_TMP_CKSUM;
    unset CONF_OP_CKSUM;
    unset TMP_CONF_CKSUM;
    unset OP_CONF_CKSUM;

    [ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "true" ] && set +x;
    [ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set +x;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +v;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +v;

    return ${RETURN_CODE};
}

#===  FUNCTION  ===============================================================
#          NAME:  decom_slave_zone
#   DESCRIPTION:  Searches for and replaces audit indicators for the provided
#                 filename.
#    PARAMETERS:  Parameters obtained via command-line flags
#          NAME:  usage for positive result, >1 for non-positive
#==============================================================================
function decom_slave_zone
{
[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "true" ] && set -x;
[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set -x;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -v;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -v;
    typeset METHOD_NAME="${CNAME}#${0}";
    typeset RETURN_CODE=0;

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Provided arguments: ${*}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Performing decommission of ${ZONE_NAME}";

    ## set up our zonefile name
    typeset CHANGE_DATE=$(date +"%m-%d-%Y");
    typeset ZONEFILE_NAME=${NAMED_ZONE_PREFIX}.$(cut -d "." -f 1 <<< ${ZONE_NAME}).${PROJECT_CODE};
    typeset LC_BUSINESS_UNIT=$(tr "[A-Z]" "[a-z]" <<< ${BUSINESS_UNIT});
    typeset CUT_ZONE=$(cut -d "." -f 1 <<< ${ZONE_NAME});
    typeset CONF_FILE=$(cut -d "/" -f 5 <<< ${NAMED_CONF_FILE});

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "ZONEFILE_NAME -> ${ZONEFILE_NAME}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Validating that requested directories/files exist..";

    ## need to make sure the provided information actually exists in the install
    if [ -d "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${BUSINESS_UNIT} ] &&
        [ -s "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${BUSINESS_UNIT}/${ZONEFILE_NAME} ] &&
        [ -s "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${BUSINESS_UNIT}/${PRIMARY_DC}/$(cut -d "." -f 1-2 <<< ${ZONEFILE_NAME}) ] &&
        [ -s "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${BUSINESS_UNIT}/${SECONDARY_DC}/$(cut -d "." -f 1-2 <<< ${ZONEFILE_NAME}) ]
    then
        ## take our backups
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backing up files..";

        ## take backups
        tar cf "${PLUGIN_BACKUP_DIR}"/${GROUP_ID}${BUSINESS_UNIT}.${CHANGE_NUM}.${CHANGE_DATE}.${REQUESTING_USER}.tar \
            -C "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT} \
            ${GROUP_ID}${BUSINESS_UNIT}/${NAMED_ZONE_PREFIX}.${CUT_ZONE}.${PROJECT_CODE} \
            ${GROUP_ID}${BUSINESS_UNIT}/${PRIMARY_DC}/${NAMED_ZONE_PREFIX}.${CUT_ZONE} \
            ${GROUP_ID}${BUSINESS_UNIT}/${SECONDARY_DC}/${NAMED_ZONE_PREFIX}.${CUT_ZONE} >> /dev/null 2>&1;
        gzip "${PLUGIN_BACKUP_DIR}"/${GROUP_ID}${BUSINESS_UNIT}.${CHANGE_NUM}.${CHANGE_DATE}.${REQUESTING_USER}.tar >> /dev/null 2>&1;

        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backup complete. Verifying..";

        ## make sure the backup tarball exists. if it doesnt, dont continue
        if [ -s "${PLUGIN_BACKUP_DIR}"/${GROUP_ID}${BUSINESS_UNIT}.${CHANGE_NUM}.${CHANGE_DATE}.${REQUESTING_USER}.tar.gz ]
        then
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backup verified. Continuing..";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Checking for ${GROUP_ID}${NAMED_DECOM_DIR}..";

            ## make sure our decom folder exists, if not, create it
            [ ! -d "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR} ] && mkdir "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR};

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Checking for ${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT}..";

            ## check if a directory already exists for our biz unit, if not, create it
            if [ ! -d "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT} ]
            then
                mkdir "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT};
                mkdir "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT}/${PRIMARY_DC};
                mkdir "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT}/${SECONDARY_DC};
            fi

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Pre-work and verification complete.";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Moving zone files..";

            ## ok, so we've done the necessary pre-work. now we move the files into the decom dir
            mv "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${BUSINESS_UNIT}/${ZONEFILE_NAME} \
                "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT}/${ZONEFILE_NAME};
            mv "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${BUSINESS_UNIT}/${PRIMARY_DC}/$(cut -d "." -f 1-2 <<< ${ZONEFILE_NAME}) \
                "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT}/${PRIMARY_DC}/$(cut -d "." -f 1-2 <<< ${ZONEFILE_NAME});
            mv "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${BUSINESS_UNIT}/${SECONDARY_DC}/$(cut -d "." -f 1-2 <<< ${ZONEFILE_NAME}) \
                "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT}/${SECONDARY_DC}/$(cut -d "." -f 1-2 <<< ${ZONEFILE_NAME});

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Move complete. Verifying..";

            ## ok, so now the files should no longer exist in their usual locations and should exist in the decom dir.
            ## lets check
            if [ -s "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT}/${ZONEFILE_NAME} ] &&
                [ -s "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT}/${PRIMARY_DC}/$(cut -d "." -f 1-2 <<< ${ZONEFILE_NAME}) ] &&
                [ -s "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT}/${SECONDARY_DC}/$(cut -d "." -f 1-2 <<< ${ZONEFILE_NAME}) ]
            then
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Move verified. Verifying file removal..";

                ## ok, we know theyre in the decom dir. make sure they arent in their usual location
                if [ ! -s "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${BUSINESS_UNIT}/${ZONEFILE_NAME} ] &&
                    [ ! -s "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${BUSINESS_UNIT}/${PRIMARY_DC}/$(cut -d "." -f 1-2 <<< ${ZONEFILE_NAME}) ] &&
                    [ ! -s "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${BUSINESS_UNIT}/${SECONDARY_DC}/$(cut -d "." -f 1-2 <<< ${ZONEFILE_NAME}) ]
                then
                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Checking if any remaining files exist..";

                    ## check if theres anything left
                    if [ $(find "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${BUSINESS_UNIT} -type f \
                        -echo | wc -l) -eq 0 ]
                    then
                        ## ok, we didnt find any files, so we can remove the directory
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No files found, removing..";

                        rm -rf "${NAMED_ROOT}"/${NAMED_ZONE_DIR}/${NAMED_SLAVE_ROOT}/${GROUP_ID}${BUSINESS_UNIT};
                    fi

                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Move verified successful. Adding entry to "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}"..";

                    ## first, create a working copy
                    if [ -s "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" ] || [ -f "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" ]
                    then
                        ## it exists.. back it up and take a copy
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backing up "${DECOM_CONF_FILE}"..";

                        cp "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" "${PLUGIN_BACKUP_DIR}/${DECOM_CONF_FILE}".${CHANGE_NUM};

                        if [ -s "${PLUGIN_BACKUP_DIR}/${DECOM_CONF_FILE}".${CHANGE_NUM} ]
                        then
                            ## good, we have a valid backup. move forward
                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Creating working copy of "${DECOM_CONF_FILE}"..";

                            cp "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";

                            if [ -s "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}" ] || [ -s "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}" ]
                            then
                                ## excellent! now we can remove it from the biz unit conf file and pipe a new entry into the decom conf file
                                ## first, add it to the decom conf file
                                echo "zone \"${ZONE_NAME}\" IN {" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                                echo "    type              slave;" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                                echo "    masters           { \"${NAMED_MASTER_ACL}\"; };" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                                echo "    file              \"${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT}/${ZONEFILE_NAME}\";" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                                echo "    allow-transfer    { key ${TSIG_TRANSFER_KEY}; };" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                                echo "};\n" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";

                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Entry added. Confirming..";

                                ## ok, so it should be in there now. verify -
                                if [ -s "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" ] &&
                                    [ $(grep -c "zone \"${ZONE_NAME}\" IN {" "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}") -eq 1 ]
                                then
                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Copying decom config file into installation..";

                                    ## great. now we can move the updated decom conf file into the installation
                                    cp "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}" "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}";

                                    ## ok. file copied. make sure
                                    DECOM_TMP_CKSUM=$(cksum "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}" | awk '{print $1}');
                                    DECOM_OP_CKSUM=$(cksum "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" | awk '{print $1}');

                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "DECOM_TMP_CKSUM -> ${DECOM_TMP_CKSUM}";
                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "DECOM_OP_CKSUM -> ${DECOM_OP_CKSUM}";

                                    if [ ${DECOM_OP_CKSUM} != ${DECOM_TMP_CKSUM} ]
                                    then
                                        ## the file copy appears to have failed. throw an error
                                        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to match checksums of decom config files. Unable to continue.";
                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                        RETURN_CODE=70;
                                    else
                                        ## file exists and entry has been added. now we can remove it from the file it originally belonged to
                                        ## make sure said file exists...
                                        if [ -s "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} ]
                                        then
                                            ## it does. take a backup..
                                            cp "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} \
                                                "${PLUGIN_BACKUP_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}.${CHANGE_NUM};

                                            if [ -s "${PLUGIN_BACKUP_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}.${CHANGE_NUM} ]
                                            then
                                                ## backup complete.
                                                ## remove entry. get the line numbers we need
                                                START_LINE_NUMBER=$(sed -n "/zone \"${ZONE_NAME}\" IN {/=" "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME});
                                                END_LINE_NUMBER=$(expr ${START_LINE_NUMBER} + 6);

                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "START_LINE_NUMBER -> ${START_LINE_NUMBER}";
                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "END_LINE_NUMBER -> ${END_LINE_NUMBER}";

                                                sed -e "${START_LINE_NUMBER},${END_LINE_NUMBER} d" "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} \
                                                    >> "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME};

                                                ## ok, should now be removed from the tmp file we've created. validate.
                                                if [ $(grep -c "zone \"${ZONE_NAME}\" IN {" "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}) -eq 0 ]
                                                then
                                                    ## lets see if the file is now empty. if it is, just delete it. we dont need it anymore.
                                                    if [ ! -s "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} ]
                                                    then
                                                        ## it is. remove it and its associated entry in named.conf
                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Validated entry removal. File has been cleared of content. Removing..";
                                                        rm -rf "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME};
                                                        rm -rf "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME};

                                                        unset START_LINE_NUMBER;
                                                        unset END_LINE_NUMBER;

                                                        ## back it up
                                                        cp ${NAMED_CONF_FILE} "${PLUGIN_BACKUP_DIR}"/${CONF_FILE}.${CHANGE_NUM};

                                                        START_LINE_NUMBER=$(sed -n "/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}/=" ${NAMED_CONF_FILE});

                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Removing entry from ${NAMED_CONF_FILE}..";

                                                        ## files removed, remove the entry in named.conf
                                                        sed -e "${START_LINE_NUMBER} d" ${NAMED_CONF_FILE} >> "${PLUGIN_TMP_DIRECTORY}"/named.conf;

                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Entry removed. Validating..";

                                                        ## ok should be gone. lets make sure.
                                                        if [ $(grep -c "${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}" "${PLUGIN_TMP_DIRECTORY}"/named.conf) -eq 0 ]
                                                        then
                                                            ## entry successfully removed. make it the normal copy.
                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Confirmed removal. Copying..";

                                                            cp "${PLUGIN_TMP_DIRECTORY}"/named.conf ${NAMED_CONF_FILE};

                                                            ## and checksum...
                                                            TMP_CONF_CKSUM=$(cksum "${PLUGIN_TMP_DIRECTORY}"/named.conf | awk '{print $1}');
                                                            OP_CONF_CKSUM=$(cksum ${NAMED_CONF_FILE} | awk '{print $1}');

                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "TMP_CONF_CKSUM -> ${TMP_CONF_CKSUM}";
                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OP_CONF_CKSUM -> ${OP_CONF_CKSUM}";

                                                            ## and validate...
                                                            if [ ${TMP_CONF_CKSUM} -eq ${OP_CONF_CKSUM} ]
                                                            then
                                                                ## check for an entry in named.conf for the decom config file. if its not
                                                                ## there then add it
                                                                if [ $(grep -c "${DECOM_CONF_FILE}" ${NAMED_CONF_FILE}) -eq 0 ]
                                                                then
                                                                    ## its not there, lets add it
                                                                    echo "include \"/"${NAMED_CONF_DIR}/${DECOM_CONF_FILE}"\";" >> ${NAMED_CONF_FILE};
                                                                fi

                                                                ## ok, checksums match, we're super.
                                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Decommission of ${ZONE_NAME} from "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} complete.";
                                                                writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone ${ZONE_NAME} decommissioned by ${REQUESTING_USER} per change ${CHANGE_NUM} on $(date +"%m-%d-%Y") at $(date +"%H:%M:%S")";

                                                                RETURN_CODE=0;
                                                            else
                                                                ## ok, so our checksums dont match. this probably means that the named conf in tmp/ didnt
                                                                ## copy to where its supposed to go. this *should* be ok, but does warrant some review. writeLogEntry "AUDIT" "${METHOD_NAME}".
                                                                writeLogEntry writeLogEntry "AUDIT" "${METHOD_NAME}" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CHECKSUM MISMATCH: Failed to validate that named configuration file was updated.";

                                                                if [ $(grep -c "${DECOM_CONF_FILE}" ${NAMED_CONF_FILE}) -eq 0 ]
                                                                then
                                                                    ## its not there, lets add it
                                                                    echo "include \"/"${NAMED_CONF_DIR}/${DECOM_CONF_FILE}"\";" >> ${NAMED_CONF_FILE};
                                                                fi

                                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Decommission of ${ZONE_NAME} from "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} complete.";
                                                                writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone ${ZONE_NAME} decommissioned by ${REQUESTING_USER} per change ${CHANGE_NUM} on $(date +"%m-%d-%Y") at $(date +"%H:%M:%S")";

                                                                RETURN_CODE=72;
                                                            fi
                                                        else
                                                            ## failed to remove entry from the named config file. we care, but not enough to fail the entire
                                                            ## process, as named will continue chugging along with an empty file. writeLogEntry "AUDIT" "${METHOD_NAME}".
                                                            writeLogEntry writeLogEntry "AUDIT" "${METHOD_NAME}" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to remove zone include statement from named configuration file.";

                                                            ## check for an entry in named.conf for the decom config file. if its not
                                                            ## there then add it
                                                            if [ $(grep -c "${DECOM_CONF_FILE}" ${NAMED_CONF_FILE}) -eq 0 ]
                                                            then
                                                                ## its not there, lets add it
                                                                echo "include \"/"${NAMED_CONF_DIR}/${DECOM_CONF_FILE}"\";" >> ${NAMED_CONF_FILE};
                                                            fi

                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Decommission of ${ZONE_NAME} from "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} complete.";
                                                            writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone ${ZONE_NAME} decommissioned by ${REQUESTING_USER} per change ${CHANGE_NUM} on $(date +"%m-%d-%Y") at $(date +"%H:%M:%S")";

                                                            RETURN_CODE=72;
                                                        fi
                                                    else
                                                        ## verified removal. lets make this file the active file and call it a day.
                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Moving "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} to "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}..";

                                                        ## checksum tmp file
                                                        CONF_TMP_CKSUM=$(cksum "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} | awk '{print $1}');

                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CONF_TMP_CKSUM -> ${CONF_TMP_CKSUM}";

                                                        mv "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} \
                                                            "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME};

                                                        ## checksum operational
                                                        CONF_OP_CKSUM=$(cksum "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} | awk '{print $1}');

                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CONF_OP_CKSUM -> ${CONF_OP_CKSUM}";

                                                        if [ ${CONF_TMP_CKSUM} -eq ${CONF_OP_CKSUM} ]
                                                        then
                                                            ## check for an entry in named.conf for the decom config file. if its not
                                                            ## there then add it
                                                            if [ $(grep -c "${DECOM_CONF_FILE}" ${NAMED_CONF_FILE}) -eq 0 ]
                                                            then
                                                                ## its not there, lets add it
                                                                echo "include \"/"${NAMED_CONF_DIR}/${DECOM_CONF_FILE}"\";" >> ${NAMED_CONF_FILE};
                                                            fi

                                                            ## we're done here.
                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Removal of ${ZONE_NAME} from "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} complete.";
                                                            writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone ${ZONE_NAME} decommissioned by ${REQUESTING_USER} per change ${CHANGE_NUM} on $(date +"%m-%d-%Y") at $(date +"%H:%M:%S")";

                                                            RETURN_CODE=0;
                                                        else
                                                            ## checksums dont match. this probably means that the file didnt move into place properly.
                                                            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Checksum mismatch against business unit configuration file. Validation failed.";

                                                            RETURN_CODE=70;
                                                        fi
                                                    fi
                                                else
                                                    ## removal of the zone from the biz conf file didn't work for some reason. return an error
                                                    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to validate that zone has been removed from the business unit configuration.";

                                                    RETURN_CODE=70;
                                                fi
                                            else
                                                ## couldnt create the backup file
                                                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to create configuration backup. Cannot continue.";
                                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                                RETURN_CODE=57;
                                            fi
                                        else
                                            ## biz conf file doesnt exist ?!
                                            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Business Unit configuration file does not exist. Please verify that the zone name provided is accurate.";

                                            RETURN_CODE=14;
                                        fi
                                    fi
                                else
                                    ## decom file failed to update with new zone
                                    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to update "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" with the new configuration.";

                                    RETURN_CODE=70;
                                fi
                            else
                                ## we were unable to create a copy of the decom conf file. fail.
                                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to update "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" with the new configuration.";

                                RETURN_CODE=70;
                            fi
                        else
                            ## we have no backup. we can't keep going.
                            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to update "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" with the new configuration.";

                            RETURN_CODE=70;
                        fi
                    else
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Found no decom conf file. Creating a new one..";

                        touch "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";

                        if [ -f "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}" ]
                        then
                            ## excellent! now we can remove it from the biz unit conf file and pipe a new entry into the decom conf file
                            ## first, add it to the decom conf file
                            echo "zone \"${ZONE_NAME}\" IN {" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                            echo "    type              slave;" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                            echo "    masters           { \"${NAMED_MASTER_ACL}\"; };" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                            echo "    file              \"${NAMED_SLAVE_ROOT}/${GROUP_ID}${NAMED_DECOM_DIR}/${GROUP_ID}${BUSINESS_UNIT}/${ZONEFILE_NAME}\";" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                            echo "    allow-transfer    { key ${TSIG_TRANSFER_KEY}; };" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";
                            echo "};\n" >> "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}";

                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Entry added. Confirming..";

                            ## ok, so it should be in there now. verify -
                            if [ $(grep -c "zone \"${ZONE_NAME}\" IN {" "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}") -eq 1 ]
                            then
                                ## great. now we can move the updated decom conf file into the installation
                                cp "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}" "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}";

                                ## ok. file copied. make sure
                                DECOM_TMP_CKSUM=$(cksum "${PLUGIN_TMP_DIRECTORY}/${DECOM_CONF_FILE}" | awk '{print $1}');
                                DECOM_OP_CKSUM=$(cksum "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" | awk '{print $1}');

                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "DECOM_TMP_CKSUM -> ${DECOM_TMP_CKSUM}";
                                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "DECOM_OP_CKSUM -> ${DECOM_OP_CKSUM}";

                                if [ ${DECOM_OP_CKSUM} != ${DECOM_TMP_CKSUM} ]
                                then
                                    ## the file copy appears to have failed. throw an error
                                    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to match checksums of decom config files. Unable to continue.";
                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                    RETURN_CODE=70;
                                else
                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Confirmation complete. Removing entry from "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME})..";

                                    ## file exists and entry has been added. now we can remove it from the file it originally belonged to
                                    ## make sure said file exists...
                                    if [ -s "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} ]
                                    then
                                        ## it does. take a backup..
                                        cp "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} \
                                            "${PLUGIN_BACKUP_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}.${CHANGE_NUM};

                                        if [ -s "${PLUGIN_BACKUP_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}.${CHANGE_NUM} ]
                                        then
                                            ## backup complete.
                                            ## remove entry. get the line numbers we need
                                            START_LINE_NUMBER=$(sed -n "/zone \"${ZONE_NAME}\" IN {/=" "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME});
                                            END_LINE_NUMBER=$(expr ${START_LINE_NUMBER} + 6);

                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "START_LINE_NUMBER -> ${START_LINE_NUMBER}";
                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "END_LINE_NUMBER -> ${END_LINE_NUMBER}";

                                            sed -e "${START_LINE_NUMBER},${END_LINE_NUMBER} d" "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} \
                                                >> "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME};

                                            ## ok, should now be removed from the tmp file we've created. validate.
                                            if [ $(grep -c "zone \"${ZONE_NAME}\" IN {" "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}) -eq 0 ]
                                            then
                                                ## lets see if the file is now empty. if it is, just delete it. we dont need it anymore.
                                                if [ ! -s "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} ]
                                                then
                                                    ## it is. remove it and its associated entry in named.conf
                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Validated entry removal. File has been cleared of content. Removing..";
                                                    rm -rf "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME};
                                                    rm -rf "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME};

                                                    unset START_LINE_NUMBER;
                                                    unset END_LINE_NUMBER;

                                                    ## back it up
                                                    cp ${NAMED_CONF_FILE} "${PLUGIN_BACKUP_DIR}"/${CONF_FILE}.${CHANGE_NUM};

                                                    START_LINE_NUMBER=$(sed -n "/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}/=" ${NAMED_CONF_FILE});

                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Removing entry from ${NAMED_CONF_FILE}..";

                                                    ## files removed, remove the entry in named.conf
                                                    sed -e "${START_LINE_NUMBER} d" ${NAMED_CONF_FILE} >> "${PLUGIN_TMP_DIRECTORY}"/named.conf;

                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Entry removed. Validating..";

                                                    ## ok should be gone. lets make sure.
                                                    if [ $(grep -c "${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}" "${PLUGIN_TMP_DIRECTORY}"/named.conf) -eq 0 ]
                                                    then
                                                        ## entry successfully removed. make it the normal copy.
                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Confirmed removal. Copying..";

                                                        cp "${PLUGIN_TMP_DIRECTORY}"/named.conf ${NAMED_CONF_FILE};

                                                        ## and checksum...
                                                        TMP_CONF_CKSUM=$(cksum "${PLUGIN_TMP_DIRECTORY}"/named.conf | awk '{print $1}');
                                                        OP_CONF_CKSUM=$(cksum ${NAMED_CONF_FILE} | awk '{print $1}');

                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "TMP_CONF_CKSUM -> ${TMP_CONF_CKSUM}";
                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OP_CONF_CKSUM -> ${OP_CONF_CKSUM}";

                                                        ## and validate...
                                                        if [ ${TMP_CONF_CKSUM} -eq ${OP_CONF_CKSUM} ]
                                                        then
                                                            ## check for an entry in named.conf for the decom config file. if its not
                                                            ## there then add it
                                                            if [ $(grep -c "${DECOM_CONF_FILE}" ${NAMED_CONF_FILE}) -eq 0 ]
                                                            then
                                                                ## its not there, lets add it
                                                                echo "include \"/"${NAMED_CONF_DIR}/${DECOM_CONF_FILE}"\";" >> ${NAMED_CONF_FILE};
                                                            fi

                                                            ## ok, checksums match, we're super.
                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Decommission of ${ZONE_NAME} from "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} complete.";
                                                            writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone ${ZONE_NAME} decommissioned by ${REQUESTING_USER} per change ${CHANGE_NUM} on $(date +"%m-%d-%Y") at $(date +"%H:%M:%S")";

                                                            RETURN_CODE=0;
                                                        else
                                                            ## ok, so our checksums dont match. this probably means that the named conf in tmp/ didnt
                                                            ## copy to where its supposed to go. this *should* be ok, but does warrant some review. writeLogEntry "AUDIT" "${METHOD_NAME}".
                                                            writeLogEntry writeLogEntry "AUDIT" "${METHOD_NAME}" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CHECKSUM MISMATCH: Failed to validate that named configuration file was updated.";

                                                            if [ $(grep -c "${DECOM_CONF_FILE}" ${NAMED_CONF_FILE}) -eq 0 ]
                                                            then
                                                                ## its not there, lets add it
                                                                echo "include \"/"${NAMED_CONF_DIR}/${DECOM_CONF_FILE}"\";" >> ${NAMED_CONF_FILE};
                                                            fi

                                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Decommission of ${ZONE_NAME} from "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} complete.";
                                                            writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone ${ZONE_NAME} decommissioned by ${REQUESTING_USER} per change ${CHANGE_NUM} on $(date +"%m-%d-%Y") at $(date +"%H:%M:%S")";

                                                            RETURN_CODE=72;
                                                        fi
                                                    else
                                                        ## failed to remove entry from the named config file. we care, but not enough to fail the entire
                                                        ## process, as named will continue chugging along with an empty file. writeLogEntry "AUDIT" "${METHOD_NAME}".
                                                        writeLogEntry writeLogEntry "AUDIT" "${METHOD_NAME}" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to remove zone include statement from named configuration file.";

                                                        ## check for an entry in named.conf for the decom config file. if its not
                                                        ## there then add it
                                                        if [ $(grep -c "${DECOM_CONF_FILE}" ${NAMED_CONF_FILE}) -eq 0 ]
                                                        then
                                                            ## its not there, lets add it
                                                            echo "include \"/"${NAMED_CONF_DIR}/${DECOM_CONF_FILE}"\";" >> ${NAMED_CONF_FILE};
                                                        fi

                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Decommission of ${ZONE_NAME} from "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} complete.";
                                                        writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone ${ZONE_NAME} decommissioned by ${REQUESTING_USER} per change ${CHANGE_NUM} on $(date +"%m-%d-%Y") at $(date +"%H:%M:%S")";

                                                        RETURN_CODE=72;
                                                    fi
                                                else
                                                    ## verified removal. lets make this file the active file and call it a day.
                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Moving "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} to "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME}..";

                                                    ## checksum tmp file
                                                    CONF_TMP_CKSUM=$(cksum "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} | awk '{print $1}');

                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CONF_TMP_CKSUM -> ${CONF_TMP_CKSUM}";

                                                    mv "${PLUGIN_TMP_DIRECTORY}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} \
                                                        "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME};

                                                    ## checksum operational
                                                    CONF_OP_CKSUM=$(cksum "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} | awk '{print $1}');

                                                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CONF_OP_CKSUM -> ${CONF_OP_CKSUM}";

                                                    if [ ${CONF_TMP_CKSUM} -eq ${CONF_OP_CKSUM} ]
                                                    then
                                                        ## check for an entry in named.conf for the decom config file. if its not
                                                        ## there then add it
                                                        if [ $(grep -c "${DECOM_CONF_FILE}" ${NAMED_CONF_FILE}) -eq 0 ]
                                                        then
                                                            ## its not there, lets add it
                                                            echo "include \"/"${NAMED_CONF_DIR}/${DECOM_CONF_FILE}"\";" >> ${NAMED_CONF_FILE};
                                                        fi

                                                        ## we're done here.
                                                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Removal of ${ZONE_NAME} from "${NAMED_ROOT}/${NAMED_CONF_DIR}"/${LC_BUSINESS_UNIT}.${NAMED_ZONE_CONF_NAME} complete.";
                                                        writeLogEntry "AUDIT" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Zone ${ZONE_NAME} decommissioned by ${REQUESTING_USER} per change ${CHANGE_NUM} on $(date +"%m-%d-%Y") at $(date +"%H:%M:%S")";

                                                        RETURN_CODE=0;
                                                    else
                                                        ## checksums dont match. this probably means that the file didnt move into place properly.
                                                        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Checksum mismatch against business unit configuration file. Validation failed.";

                                                        RETURN_CODE=70;
                                                    fi
                                                fi
                                            else
                                                ## removal of the zone from the biz conf file didn't work for some reason. return an error
                                                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to validate that zone has been removed from the business unit configuration.";

                                                RETURN_CODE=70;
                                            fi
                                        else
                                            ## couldnt create the backup file
                                            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to create configuration backup. Cannot continue.";
                                            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                            RETURN_CODE=57;
                                        fi
                                    else
                                        ## biz conf file doesnt exist ?!
                                        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Business Unit configuration file does not exist. Please verify that the zone name provided is accurate.";

                                        RETURN_CODE=14;
                                    fi
                                fi
                            else
                                ## decom file failed to update with new zone
                                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to update "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" with the new configuration.";

                                RETURN_CODE=70;
                            fi
                        else
                            ## we were unable to create a copy of the decom conf file. fail.
                            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to update "${NAMED_ROOT}/${NAMED_CONF_DIR}/${DECOM_CONF_FILE}" with the new configuration.";

                            RETURN_CODE=70;
                        fi
                    fi
                else
                    ## move failed. really this should be a warning, but we're going to
                    ## fail because it makes more sense to fail and investigate the issue
                    ## than it does to leave the files in place and just keep going
                    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to move files from Business Unit directory to ${NAMED_DECOM_DIR}.";

                    RETURN_CODE=70;
                fi
            else
                ## move failed. really this should be a warning, but we're going to
                ## fail because it makes more sense to fail and investigate the issue
                ## than it does to leave the files in place and just keep going
                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to move files from Business Unit directory to ${NAMED_DECOM_DIR}.";

                RETURN_CODE=70;
            fi
        else
            ## failed to create a backup of the existing configuration
            writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to create zone configuration backup. Cannot continue.";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

            RETURN_CODE=57;
        fi
    else
        ## we were provided information necessary to perform the work, but the information given doesnt map to
        ## actual files/directories on the filesystem. cant operate with nothing to operate against
        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to create zone configuration backup. Cannot continue.";
        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

        RETURN_CODE=12;
    fi

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

    ## remove any tmp files
    [ -f "${PLUGIN_TMP_DIRECTORY}"/named.conf ] && rm -rf "${PLUGIN_TMP_DIRECTORY}"/named.conf;

    unset END_LINE_NUMBER;
    unset START_LINE_NUMBER;
    unset ZONEFILE_NAME;
    unset CONF_TMP_CKSUM;
    unset CONF_OP_CKSUM;
    unset TMP_CONF_CKSUM;
    unset OP_CONF_CKSUM;

    [ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "true" ] && set +x;
    [ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set +x;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +v;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +v;

    return ${RETURN_CODE};
}

#===  FUNCTION  ===============================================================
#          NAME:  usage
#   DESCRIPTION:  Provide information on the function usage of this application
#    PARAMETERS:  None
#==============================================================================
function usage
{
[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "true" ] && set -x;
[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set -x;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set -v;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set -v;
    typeset METHOD_NAME="${CNAME}#${0}";
    typeset RETURN_CODE=3;

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Provided arguments: ${*}";

    echo "${THIS_CNAME} - Execute modifications against a zone\n" >&2;
    echo "Usage: ${THIS_CNAME} [ -b <business unit> ] [ -p <project code> ] [ -z <zone name> ] [ -i <requesting user> ] [ -c <change request> ] [ -d <change date> ] [ -s ] [ -e ] [ -h|-? ]
    -b         -> The associated business unit.
    -p         -> The associated project code. Optional if a business unit is being decommissioned
    -z         -> The zone name, eg example.com. Optional if a business unit is being decommissioned
    -i         -> The user performing the request.
    -c         -> The change order associated with this request.
    -s         -> Specifies whether or not to operate against a slave server
    -e         -> Execute processing
    -h|-?      -> Show this help\n" >&2;

    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RETURN_CODE -> ${RETURN_CODE}";
    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

    [ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "true" ] && set +x;
    [ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set +x;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +v;
    [ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +v;

    return ${RETURN_CODE};
}

[ ${#} -eq 0 ] && usage; RETURN_CODE=${?};

while getopts ":b:p:z:i:c:seh:" OPTIONS 2>/dev/null
do
    case "${OPTIONS}" in
        b)
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting BUSINESS_UNIT..";

            ## Capture the site root
            typeset -u BUSINESS_UNIT="${OPTARG}";

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "BUSINESS_UNIT -> ${BUSINESS_UNIT}";
            ;;
        p)
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting PROJECT_CODE..";

            ## Capture the site root
            typeset -u PROJECT_CODE="${OPTARG}";

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PROJECT_CODE -> ${PROJECT_CODE}";
            ;;
        z)
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting ZONE_NAME..";

            ## Capture the site root
            ZONE_NAME=${OPTARG};

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "ZONE_NAME -> ${ZONE_NAME}";
            ;;
        i)
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting REQUESTING_USER..";

            ## Capture the change control
            REQUESTING_USER="${OPTARG}";

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "REQUESTING_USER -> ${REQUESTING_USER}";
            ;;
        c)
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting CHANGE_NUM..";

            ## Capture the change control
            typeset -u CHANGE_NUM="${OPTARG}";

            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CHANGE_NUM -> ${CHANGE_NUM}";
            ;;
        s)
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting SLAVE_OPERATION to true..";

            ## Capture the change control
            SLAVE_OPERATION=${_TRUE};
            ;;
        e)
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Validating request..";

            if [ -z "${BUSINESS_UNIT}" ]
            then
                writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No business unit was provided. Unable to continue processing.";
                [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                RETURN_CODE=15;
            else
                if [ -z "${REQUESTING_USER}" ]
                then
                    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "The requestors username was not provided. Unable to continue processing.";
                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                    RETURN_CODE=20;
                elif [ -z "CHANGE_NUM" ]
                then
                    writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No change order was provided. Unable to continue processing.";
                    [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                    RETURN_CODE=17;
                else
                    if [ ! -z "${PROJECT_CODE}" ] && [ -z "${ZONE_NAME}" ] || [ -z "${PROJECT_CODE}" ] && [ ! -z "${ZONE_NAME}" ]
                    then
                        writeLogEntry "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No zone name was provided. Unable to continue processing.";
                        [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                        RETURN_CODE=24;
                    elif [ ! -z "${PROJECT_CODE}" ] && [ ! -z "${ZONE_NAME}" ]
                    then
                        [ ! -z "${SLAVE_OPERATION}" ] && [ "${SLAVE_OPERATION}" = "${_TRUE}" ] && decom_slave_zone && RETURN_CODE=${?} || decom_master_zone; RETURN_CODE=${?};
                    else
                        [ ! -z "${SLAVE_OPERATION}" ] && [ "${SLAVE_OPERATION}" = "${_TRUE}" ] && decom_slave_bu && RETURN_CODE=${?} || decom_master_bu; RETURN_CODE=${?};
                    fi
                fi
            fi
            ;;
        *)
            [ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

            usage; RETURN_CODE=${?};
            ;;
    esac
done

trap 'unlockProcess "${LOCKFILE}" "${$}"; return "${RETURN_CODE}"' INT TERM EXIT;

[ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RETURN_CODE -> ${RETURN_CODE}";
[ ! -z "${ENABLE_DEBUG}" ] && [ "${ENABLE_DEBUG}" = "${_TRUE}" ] && writeLogEntry "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${CNAME} -> exit";

unset SCRIPT_ABSOLUTE_PATH;
unset SCRIPT_ROOT;
unset RET_CODE;
unset CNAME;
unset METHOD_NAME;

[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "true" ] && set +x;
[ ! -z "${ENABLE_VERBOSE}" ] && [ "${ENABLE_VERBOSE}" = "${_TRUE}" ] && set +x;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "true" ] && set +v;
[ ! -z "${ENABLE_TRACE}" ] && [ "${ENABLE_TRACE}" = "${_TRUE}" ] && set +v;

[ -z "${RETURN_CODE}" ] && echo "1" || echo "${RETURN_CODE}";
[ -z "${RETURN_CODE}" ] && return 1 || return "${RETURN_CODE}";
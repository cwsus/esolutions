#!/usr/bin/env ksh
#==============================================================================
#
#          FILE:  runCertRenewal.sh.sh
#         USAGE:  ./runCertRenewal.sh.sh
#   DESCRIPTION:  Executes the addition of a new or updated zone to the DNS
#                 master.
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
#          NAME:  create_working_copy
#   DESCRIPTION:  Creates the zone file that the DNS servers will utilize during
#                 queries. Takes the previously configured file from the primary
#                 datacenter folder and adds required indicator flags, and then
#                 places the resultant file in the group root.
#    PARAMETERS:  None
#       RETURNS:  0
#==============================================================================
function renewiPlanetCert
{
    [[ ! -z "${TRACE}" && "${TRACE}" = "${_TRUE}" ]] && set -x;
    local METHOD_NAME="${CNAME}#${0}";

    ## get some preliminary information
    CERTIFICATE_NICKNAME=$(certutil -L -d ${APP_ROOT}/${CERTDB_STORE} -P ${CERTIFICATE_DATABASE} | grep "u,u,u" | awk '{print $1}');
    NOTIFY_CERT_EXPIRY=$(certutil -L -d ${APP_ROOT}/${CERTDB_STORE} -P ${CERTIFICATE_DATABASE} -n ${CERTIFICATE_NICKNAME} | grep "Not After" | cut -d ":" -f 2- | awk '{print $1, $2, $3, $5}');
    PRE_CERT_EXPIRY=$(certutil -L -d ${APP_ROOT}/${CERTDB_STORE} -P ${CERTIFICATE_DATABASE} -n ${CERTIFICATE_NICKNAME} | grep "Not After" | awk '{print $8, $5, $6}');
    PRE_EXPIRY_MONTH=$(echo ${PRE_CERT_EXPIRY} | awk '{print $2}');
    
    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CERTIFICATE_NICKNAME -> ${CERTIFICATE_NICKNAME}";
    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "NOTIFY_CERT_EXPIRY -> ${NOTIFY_CERT_EXPIRY}";
    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PRE_CERT_EXPIRY -> ${PRE_CERT_EXPIRY}";
    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PRE_EXPIRY_MONTH -> ${PRE_EXPIRY_MONTH}";
    
    if [ ! -z "${PRE_CERT_EXPIRY}" ]
    then
        ## ok, we have a nickname and an expiration date. convert it
        PRE_EPOCH_EXPIRY=$(returnEpochTime $(echo ${PRE_CERT_EXPIRY} | sed -e "s/${EXPIRY_MONTH}/$(eval echo \${${PRE_EXPIRY_MONTH}})/"));

        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PRE_EPOCH_EXPIRY -> ${PRE_EPOCH_EXPIRY}";
        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "NOTIFY_CERT_EXPIRY -> ${NOTIFY_CERT_EXPIRY}";

        sed -e 's/^ *//' -e 's/ *$//' -e '/^$/d' ${APP_ROOT}/${CERTSTORE}/${CERTIFICATE_DATABASE}.cer > ${APP_ROOT}/${CERTSTORE}/${CERTIFICATE_NICKNAME}.cer;

        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Cleanup complete. Validating..";

        if [ -s ${APP_ROOT}/${CERTSTORE}/${CERTIFICATE_NICKNAME}.cer ]
        then
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Validation complete. Applying certificate..";

            ## remove the old
            rm -rf ${APP_ROOT}/${CERTSTORE}/${CERTIFICATE_DATABASE}.cer > /dev/null 2>&1;

            ## xlnt. delete the existing
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command certutil -D -n ${CERTIFICATE_NICKNAME} -d ${APP_ROOT}/${CERTDB_STORE} -P ${CERTIFICATE_DATABASE}..";

            certutil -D -n ${CERTIFICATE_NICKNAME} -d ${APP_ROOT}/${CERTDB_STORE} -P ${CERTIFICATE_DATABASE} >> ${APP_ROOT}/${LOG_ROOT}/certutil.${SITE_DOMAIN_NAME}.${IUSER_AUDIT} 2>&1;
            RET_CODE=${?};

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";

            if [ ${RET_CODE} != 0 ]
            then
                ## certificate wasn't removed from database.
                ## this should prolly be a warning
                $(${LOGGER} "WARN"ING "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate removal FAILED.");

                NOTIFY_WARNING=${_TRUE};
                WARNING_TYPE=96;
            fi

            ## validate its removal..
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command certutil -L -d ${APP_ROOT}/${CERTDB_STORE} -P ${CERTIFICATE_DATABASE} -n ${CERTIFICATE_NICKNAME}..";

            certutil -L -d ${APP_ROOT}/${CERTDB_STORE} -P ${CERTIFICATE_DATABASE} -n ${CERTIFICATE_NICKNAME} >> ${APP_ROOT}/${LOG_ROOT}/certutil.${SITE_DOMAIN_NAME}.${IUSER_AUDIT} 2>&1;
            RET_CODE=${?};

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";

            if [ ${RET_CODE} == 0 ]
            then
                ## cert wasnt removed. error out
                $(${LOGGER} "WARN"ING "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate removal FAILED.");

                NOTIFY_WARNING=${_TRUE};
                WARNING_TYPE=96;
            fi

            ## good. now import the new
            unset RET_CODE;

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command certutil -d ${APP_ROOT}/${CERTDB_STORE} -A -i ${APP_ROOT}/${CERTSTORE}/${CERTIFICATE_NICKNAME}.cer -n ${CERTIFICATE_NICKNAME} -t \"u,u,u\"  -P ${CERTIFICATE_DATABASE}..";

            certutil -d ${APP_ROOT}/${CERTDB_STORE} -A -i ${APP_ROOT}/${CERTSTORE}/${CERTIFICATE_NICKNAME}.cer -n ${CERTIFICATE_NICKNAME} -t "u,u,u"  -P ${CERTIFICATE_DATABASE} >> ${APP_ROOT}/${LOG_ROOT}/certutil.${SITE_DOMAIN_NAME}.${IUSER_AUDIT} 2>&1;
            RET_CODE=${?};

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";

            if [ ${RET_CODE} != 0 ]
            then
                ## an error occurred importing the cert
                ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "An error occurred during keystore certificate renewal. Cannot continue.";

                RETURN_CODE=17;
            else
                ## cert was applied, validate that its the right one
                RENEWED_CERTIFICATE_NICKNAME=$(certutil -L -d ${APP_ROOT}/${CERTDB_STORE} -P ${CERTIFICATE_DATABASE} | grep "u,u,u" | awk '{print $1}');
                POST_CERT_EXPIRY=$(certutil -L -d ${APP_ROOT}/${CERTDB_STORE} -P ${CERTIFICATE_DATABASE} -n ${CERTIFICATE_NICKNAME} | grep "Not After" | awk '{print $8, $5, $6}');
                NOTIFY_RENEWED_CERT_EXPIRY=$(certutil -L -d ${APP_ROOT}/${CERTDB_STORE} -P ${CERTIFICATE_DATABASE} -n ${CERTIFICATE_NICKNAME} | grep "Not After" | cut -d ":" -f 2- | awk '{print $1, $2, $3, $5}');

                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RENEWED_CERTIFICATE_NICKNAME -> ${RENEWED_CERTIFICATE_NICKNAME}";
                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "POST_CERT_EXPIRY -> ${POST_CERT_EXPIRY}";
                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "NOTIFY_RENEWED_CERT_EXPIRY -> ${NOTIFY_RENEWED_CERT_EXPIRY}";

                if [ ! -z "${POST_CERT_EXPIRY}" ]
                then
                    ## capture the epoch
                    POST_EPOCH_EXPIRY=$(returnEpochTime $(echo ${POST_CERT_EXPIRY} | sed -e "s/${EXPIRY_MONTH}/$(eval echo \${${EXPIRY_MONTH}})/"));

                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "POST_EPOCH_EXPIRY -> ${POST_EPOCH_EXPIRY}";

                    if [ ! -z "${POST_EPOCH_EXPIRY}" ]
                    then
                        if [ ! -z "${RENEWED_CERTIFICATE_NICKNAME}" ] \
                            && [ ${PRE_EPOCH_EXPIRY} != ${POST_EPOCH_EXPIRY} ]
                        then
                            ## export it out for import into crypto
                            ## some boxes might not have crypto. we dont
                            ## care at this point, but the executor will.
                            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate successfully applied to certificate databases. Generating PKCS12 file..";
                            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && $(${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command pk12util -o ${APP_ROOT}/${PKCS12STORE}/${CERTIFICATE_NICKNAME}.pkcs" \
                                "-n ${CERTIFICATE_NICKNAME} -d ${APP_ROOT}/${CERTDB_STORE}" \
                                "-P ${CERTIFICATE_DATABASE} -k ${APP_ROOT}/${IPLANET_CERT_DB_PASSFILE}" \
                                "-w ${APP_ROOT}/${IPLANET_CERT_DB_PASSFILE} >> ${APP_ROOT}/${LOG_ROOT}/pk12util.${SITE_DOMAIN_NAME}.${IUSER_AUDIT} 2>&1 ..");

                            if [ "${VERBOSE}" = "${_TRUE}" ]
                            then
                                pk12util -o ${APP_ROOT}/${PKCS12STORE}/${CERTIFICATE_NICKNAME}.pkcs -n ${CERTIFICATE_NICKNAME} -d ${APP_ROOT}/${CERTDB_STORE} \
                                    -P ${CERTIFICATE_DATABASE} -k ${APP_ROOT}/${IPLANET_CERT_DB_PASSFILE} -w ${APP_ROOT}/${IPLANET_CERT_DB_PASSFILE};
                            else
                                pk12util -o ${APP_ROOT}/${PKCS12STORE}/${CERTIFICATE_NICKNAME}.pkcs -n ${CERTIFICATE_NICKNAME} -d ${APP_ROOT}/${CERTDB_STORE} \
                                    -P ${CERTIFICATE_DATABASE} -k ${APP_ROOT}/${IPLANET_CERT_DB_PASSFILE} -w ${APP_ROOT}/${IPLANET_CERT_DB_PASSFILE} >> ${APP_ROOT}/${LOG_ROOT}/pk12util.${SITE_DOMAIN_NAME}.${IUSER_AUDIT} 2>&1;
                            fi

                            RET_CODE=${?};

                            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE->${RET_CODE}";

                            if [ ${RET_CODE} != 0 ]
                            then
                                ## an error occurred generating the pkcs file
                                ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "An error occurred generating the PKCS12 file for crypto database import. Please try again.";

                                RETURN_CODE=18;
                            else
                                ## got a return code of zero. make sure the file got created..
                                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate export successful. Validating..";

                                if [ -s ${APP_ROOT}/${PKCS12STORE}/${CERTIFICATE_NICKNAME}.pkcs ]
                                then
                                    ## it did. find out if this is a tealeaf site
                                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate export successfully validated. Checking TeaLeaf data..";

                                    if [ $(grep -c ${SITE_DOMAIN_NAME} ${APP_ROOT}/${PEM_SITES_LIST}) != 0 ]
                                    then
                                        ## ok, we know we need to generate a pem. lets do it
                                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${SITE_DOMAIN_NAME} has a TeaLeaf requirement. Generating PEM file..";
                                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && $(${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command openssl pkcs12 -nodes -nocerts -in " \
                                            "${APP_ROOT}/${PKCS12STORE}/${CERTIFICATE_NICKNAME}.pkcs" \
                                            "-out ${APP_ROOT}/${PEMSTORE}/${CERTIFICATE_NICKNAME}.pem" \
                                            "-password file:${APP_ROOT}/${IPLANET_CERT_DB_PASSFILE}");

                                        ## this can be executed with or without tcl. both are available.
                                        if [ "${VERBOSE}" = "${_TRUE}" ]
                                        then
                                            openssl pkcs12 -nodes -nocerts -in ${APP_ROOT}/${PKCS12STORE}/${CERTIFICATE_NICKNAME}.pkcs \
                                                -out ${APP_ROOT}/${PEMSTORE}/${CERTIFICATE_NICKNAME}.pem \
                                                -password file:${APP_ROOT}/${IPLANET_CERT_DB_PASSFILE};
                                        else
                                            openssl pkcs12 -nodes -nocerts -in ${APP_ROOT}/${PKCS12STORE}/${CERTIFICATE_NICKNAME}.pkcs \
                                                -out ${APP_ROOT}/${PEMSTORE}/${CERTIFICATE_NICKNAME}.pem \
                                                -password file:${APP_ROOT}/${IPLANET_CERT_DB_PASSFILE} >> ${APP_ROOT}/${LOG_ROOT}/openssl.${SITE_DOMAIN_NAME}.${IUSER_AUDIT} 2>&1;
                                        fi

                                        RET_CODE=${?};

                                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE->${RET_CODE}";

                                        if [ ${RET_CODE} == 0 ]
                                        then
                                            ## make sure the pem got created
                                            if [ -s ${APP_ROOT}/${PEMSTORE}/${CERTIFICATE_NICKNAME}.pem ]
                                            then
                                                ## it did, good. mail it out.
                                                unset CNAME;
                                                unset METHOD_NAME;
                                                RR_OPTIND=${OPTIND};
                                                OPTIND=0;

                                                . ${MAILER_CLASS} -m ${NOTIFY_PEM_EMAIL} -p ${WEB_PROJECT_CODE} -a "${NOTIFY_PEM_ADDRESS}" -t ${NOTIFY_TYPE_NOTIFY} -e;
                                                MAILER_CODE=${?};

                                                OPTIND=${RR_OPTIND};
                                                CNAME=$(basename ${0});
                                                [[ ! -z "${TRACE}" && "${TRACE}" = "${_TRUE}" ]] && set -x;
    local METHOD_NAME="${CNAME}#${0}";

                                                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "MAILER_CODE->${MAILER_CODE}";

                                                if [ ${MAILER_CODE} != 0 ]
                                                then
                                                    ## error occurred sending the pem, warn
                                                    ${LOGGER} "WARN" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PEM file send FAILED. Please process manually.";

                                                    RETURN_CODE=97;
                                                else
                                                    ## all done.
                                                    ${LOGGER} AUDIT "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate Renewal (pre-implementation) by ${IUSER_AUDIT}: Site: ${SITE_DOMAIN_NAME}; Certificate Database: ${CERTIFICATE_DATABASE_STORE}; Certificate Nickname: ${CERTIFICATE_NICKNAME}; New expiration: ${RENEWED_CERT_EXPIRY}";

                                                    RETURN_CODE=0;
                                                fi
                                            else
                                                ## no pemfile generated
                                                ${LOGGER} AUDIT "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PEM file generated FAILED. Please try again.";

                                                RETURN_CODE=19;
                                            fi
                                        else
                                            ## non-zero return code from openssl
                                            ${LOGGER} AUDIT "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PEM file generated FAILED. Please try again.";

                                            RETURN_CODE=19;
                                        fi
                                    else
                                        ## no pem required for this site. exit out.
                                        ${LOGGER} AUDIT "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate Renewal (pre-implementation) by ${IUSER_AUDIT}: Site: ${SITE_DOMAIN_NAME}; Certificate Database: ${CERTIFICATE_DATABASE_STORE}; Certificate Nickname: ${CERTIFICATE_NICKNAME}; New expiration: ${RENEWED_CERT_EXPIRY}";

                                        RETURN_CODE=0;
                                    fi
                                else
                                    ## zero return code but no pkcs file. no good
                                    ## this might be non-fatal, if the environment
                                    ## being applied to doesnt have a crypto card
                                    ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate successfully renewed against database files, but pkcs file for metaslot failed to generate. Please try again.";

                                    RETURN_CODE=13;
                                fi
                            fi
                        else
                            ## cert imported didnt match what we were expecting. error out
                            ## TODO: maybe start over ?
                            ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate renewal against database files has FAILED - New certificate expiration matches old certificate expiration. Please try again.";

                            RETURN_CODE=14;
                        fi
                    else
                        ## post epoch expiry empty
                        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate renewal against database files has FAILED - Unable to obtain post renewal certificate expiration. Please try again.";

                        RETURN_CODE=14;
                    fi
                else
                    ## post cert expiry empty
                    ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate renewal against database files has FAILED - Unable to obtain post renewal certificate expiration. Please try again.";

                    RETURN_CODE=14;
                fi
            fi
        else
            ## we werent given a cert. error
            ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No certificate was found for ${SITE_DOMAIN_NAME}. Cannot continue.";

            RETURN_CODE=15;
        fi
    else
        ## unable to determine existing certificate expiration date
        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate renewal against database files has FAILED - Unable to obtain pre-renewal certificate expiration. Please try again.";

        RETURN_CODE=14;
    fi

    unset CERTIFICATE_DATABASE;
    unset CERTIFICATE_NICKNAME;
    unset SITE_DOMAIN_NAME;
    unset CERTIFICATE_EXPIRY;
    unset RET_CODE;
    unset RENEWED_CERTIFICATE_NICKNAME;
    unset RENEWED_CERT_EXPIRY;
    unset MAILER_CODE;

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";
}

#===  FUNCTION  ===============================================================
#          NAME:  create_working_copy
#   DESCRIPTION:  Creates the zone file that the DNS servers will utilize during
#                 queries. Takes the previously configured file from the primary
#                 datacenter folder and adds required indicator flags, and then
#                 places the resultant file in the group root.
#    PARAMETERS:  None
#       RETURNS:  0
#==============================================================================
function renewIHSCert
{
    [[ ! -z "${TRACE}" && "${TRACE}" = "${_TRUE}" ]] && set -x;
    local METHOD_NAME="${CNAME}#${0}";

    ## get some preliminary information
    ## gsk7 is a punk, so we exported first. the export has
    ## the friendly name (nickname) and the expiry date
    typeset -u CERTIFICATE_NICKNAME=$(grep friendlyName ${APP_ROOT}/${PEMSTORE}/${CERTIFICATE_DATABASE}.pem | cut -d ":" -f 2 | \
        sed -e "s/^ *//g" | sort | uniq);
    CERTIFICATE_EXPIRY=$(openssl x509 -noout -in ${APP_ROOT}/${PEMSTORE}/${CERTIFICATE_DATABASE}.pem -dates | grep notAfter | \
        cut -d "=" -f 2 | awk '{print $4}');
    NOTIFY_CERT_EXPIRY=$(openssl x509 -noout -in ${APP_ROOT}/${PEMSTORE}/${CERTIFICATE_DATABASE}.pem -dates | grep notAfter | \
        cut -d "=" -f 2 | awk '{print $1, $2, $4}');

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CERTIFICATE_NICKNAME -> ${CERTIFICATE_NICKNAME}";
    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CERTIFICATE_EXPIRY -> ${CERTIFICATE_EXPIRY}";

    if [ -s ${APP_ROOT}/${CERTSTORE}/${CERTIFICATE_DATABASE}.cer ]
    then
        ## got it. clean it up if necessary
        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate validated. Removing extra spaces and linebreaks..";

        sed -e 's/^ *//' -e 's/ *$//' -e '/^$/d' ${APP_ROOT}/${CERTSTORE}/${CERTIFICATE_DATABASE}.cer > ${APP_ROOT}/${CERTSTORE}/${CERTIFICATE_NICKNAME}.cer;

        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Cleanup complete. Validating..";

        if [ -s ${APP_ROOT}/${CERTSTORE}/${CERTIFICATE_NICKNAME}.cer ]
        then
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Validation complete. Applying certificate..";

            ## looks good, clean up
            rm -rf ${APP_ROOT}/${CERTSTORE}/${CERTIFICATE_DATABASE}.cer > /dev/null 2>&1;

            ## xlnt. apply it.
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate validated. Continuing..";
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command keyman -cert -receive -db ${APP_ROOT}/${CERTDB_STORE}/${CERTIFICATE_DATABASE}${IHS_DB_CRT_SUFFIX} -file ${APP_ROOT}/${CERT_STORE}/${CERTIFICATE_NICKNAME}.cer -pw $(cat ${APP_ROOT}/${IHS_CERT_DB_PASSFILE}) -type ${IHS_KEY_DB_TYPE} -format ascii";

            keyman -cert -receive -db ${APP_ROOT}/${CERTDB_STORE}/${CERTIFICATE_DATABASE}${IHS_DB_CRT_SUFFIX} \
                -file ${APP_ROOT}/${CERTSTORE}/${CERTIFICATE_NICKNAME}.cer -pw $(cat ${APP_ROOT}/${IHS_CERT_DB_PASSFILE}) \
                -type ${IHS_KEY_DB_TYPE} -format ascii;

            RET_CODE=${?};

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";

            if [ ${RET_CODE} != 0 ]
            then
                ## an error occurred importing the cert
                ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "An error occurred during keystore certificate renewal. Cannot continue.";

                RETURN_CODE=17;
            else
                ## cert was applied, validate that its the right one
                RENEWED_CERT_NICKNAME=$(keyman -cert -list personal -db ${APP_ROOT}/${CERTDB_STORE}/${CERTIFICATE_DATABASE}${IHS_DB_CRT_SUFFIX} \
                    -pw $(cat ${APP_ROOT}/${IHS_CERT_DB_PASSFILE}) -type ${IHS_KEY_DB_TYPE} | grep -v ${CERTIFICATE_DATABASE} | sed -e "s/^ *//g");
                RENEWED_CERT_EXPIRY=$(keyman -cert -details -db ${APP_ROOT}/${CERTDB_STORE}/${CERTIFICATE_DATABASE}${IHS_DB_CRT_SUFFIX} \
                    -pw $(cat ${APP_ROOT}/${IHS_CERT_DB_PASSFILE}) -label ${CERTIFICATE_NICKNAME} | grep Valid | cut -d ":" -f 7- | awk '{print $4}');

                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RENEWED_CERT_NICKNAME -> ${RENEWED_CERT_NICKNAME}";
                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RENEWED_CERT_EXPIRY -> ${RENEWED_CERT_EXPIRY}";

                if [ ! -z "${RENEWED_CERT_NICKNAME}" ] \
                    && [ ${CERTIFICATE_EXPIRY} != ${RENEWED_CERT_EXPIRY} ]
                then
                    ## check if its a pem site. if it is, then do the work,
                    ## otherwise, skip
                    if [ $(grep -c ${SITE_DOMAIN_NAME} ${APP_ROOT}/${PEM_SITES_LIST}) != 0 ]
                    then
                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate successfully applied to certificate databases. Generating PKCS12 file..";
                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command keyman -cert -export -db ${APP_ROOT}/${CERTDB_STORE}/${CERTIFICATE_NICKNAME}${IHS_DB_CRT_SUFFIX} -label ${CERTIFICATE_NICKNAME} -target ${APP_ROOT}/${PKCS12STORE}/${CERTIFICATE_NICKNAME}.pkcs -pw $(cat ${APP_ROOT}/${IHS_CERT_DB_PASSFILE}) -target_pw $(cat ${APP_ROOT}/${IHS_CERT_DB_PASSFILE}) -target_type pkcs12 -encryption strong";

                        keyman -cert -export -db ${APP_ROOT}/${CERTDB_STORE}/${CERTIFICATE_DATABASE}${IHS_DB_CRT_SUFFIX} \
                            -label ${CERTIFICATE_NICKNAME} -target ${APP_ROOT}/${PKCS12STORE}/${CERTIFICATE_NICKNAME}.pkcs \
                            -pw $(cat ${APP_ROOT}/${IHS_CERT_DB_PASSFILE}) -target_pw $(cat ${APP_ROOT}/${IHS_CERT_DB_PASSFILE}) -target_type pkcs12 -encryption strong;

                        RET_CODE=${?};

                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE->${RET_CODE}";

                        if [ ${RET_CODE} != 0 ]
                        then
                            ## an error occurred generating the pkcs file
                            ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "An error occurred generating the PKCS12 file for crypto database import. Please try again.";

                            RETURN_CODE=18;
                        else
                            ## got a return code of zero. make sure the file got created..
                            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate export successful. Validating..";

                            if [ -s ${APP_ROOT}/${PKCS12STORE}/${CERTIFICATE_NICKNAME}.pkcs ]
                            then
                                ## ok, we know we need to generate a pem. lets do it
                                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${SITE_DOMAIN_NAME} has a TeaLeaf requirement. Generating PEM file..";
                                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command openssl pkcs12 -nodes -nocerts -in ${APP_ROOT}/${PKCS12STORE}/${CERTIFICATE_NICKNAME}.pkcs -out ${APP_ROOT}/${PEMSTORE}/${CERTIFICATE_NICKNAME}.pem -password file:${APP_ROOT}/${IHS_CERT_DB_PASSFILE}";

                                ## this can be executed with or without tcl. both are available.
                                if [ "${VERBOSE}" = "${_TRUE}" ]
                                then
                                    openssl pkcs12 -nodes -nocerts -in ${APP_ROOT}/${PKCS12STORE}/${CERTIFICATE_NICKNAME}.pkcs \
                                        -out ${APP_ROOT}/${PEMSTORE}/${CERTIFICATE_NICKNAME}.pem \
                                        -password file:${APP_ROOT}/${IHS_CERT_DB_PASSFILE};
                                else
                                    openssl pkcs12 -nodes -nocerts -in ${APP_ROOT}/${PKCS12STORE}/${CERTIFICATE_NICKNAME}.pkcs \
                                        -out ${APP_ROOT}/${PEMSTORE}/${CERTIFICATE_NICKNAME}.pem \
                                        -password file:${APP_ROOT}/${IHS_CERT_DB_PASSFILE} >> ${APP_ROOT}/${LOG_ROOT}/openssl.${SITE_DOMAIN_NAME}.${IUSER_AUDIT} 2>&1;
                                fi

                                RET_CODE=${?};

                                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE->${RET_CODE}";

                                if [ ${RET_CODE} == 0 ]
                                then
                                    ## make sure the pem got created
                                    if [ -s ${APP_ROOT}/${PEMSTORE}/${CERTIFICATE_NICKNAME}.pem ]
                                    then
                                        ## it did, good. mail it out.
                                        unset CNAME;
                                        unset METHOD_NAME;

                                        . ${MAILER_CLASS} -m ${NOTIFY_PEM_EMAIL} -p ${WEB_PROJECT_CODE} -a "${NOTIFY_PEM_ADDRESS}" -t ${NOTIFY_TYPE_NOTIFY} -e;
                                        MAILER_CODE=${?};

                                        CNAME=$(basename ${0});
                                        [[ ! -z "${TRACE}" && "${TRACE}" = "${_TRUE}" ]] && set -x;
    local METHOD_NAME="${CNAME}#${0}";

                                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "MAILER_CODE->${MAILER_CODE}";

                                        if [ ${MAILER_CODE} != 0 ]
                                        then
                                            ## error occurred sending the pem, warn
                                            ${LOGGER} "WARN" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PEM file send FAILED. Please process manually.";

                                            RETURN_CODE=97;
                                        else
                                            ## all done.
                                            ${LOGGER} AUDIT "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate Renewal (pre-implementation) by ${IUSER_AUDIT}: Site: ${SITE_DOMAIN_NAME}; Certificate Database: ${CERTIFICATE_DATABASE_STORE}; Certificate Nickname: ${CERTIFICATE_NICKNAME}; New expiration: ${RENEWED_CERT_EXPIRY}";

                                            RETURN_CODE=0;
                                        fi
                                    else
                                        ## no pemfile generated
                                        ${LOGGER} AUDIT "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PEM file generated FAILED. Please try again.";

                                        RETURN_CODE=19;
                                    fi
                                else
                                    ## non-zero return code from openssl
                                    ${LOGGER} AUDIT "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PEM file generated FAILED. Please try again.";

                                    RETURN_CODE=19;
                                fi
                            else
                                ## zero return code but no pkcs file. no good
                                ## this might be non-fatal, if the environment
                                ## being applied to doesnt have a crypto card
                                ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate successfully renewed against database files, but pkcs file for metaslot failed to generate. Please try again.";

                                RETURN_CODE=13;
                            fi
                        fi
                    else
                        ${LOGGER} AUDIT "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate Renewal (pre-implementation) by ${IUSER_AUDIT}: Site: ${SITE_DOMAIN_NAME}; Certificate Database: ${CERTIFICATE_DATABASE_STORE}; Certificate Nickname: ${CERTIFICATE_NICKNAME}; New expiration: ${RENEWED_CERT_EXPIRY}";

                        RETURN_CODE=0;
                    fi
                else
                    ## cert imported didnt match what we were expecting. error out
                    ## TODO: maybe start over ?
                    ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate renewal against database files has FAILED. Please try again.";

                    RETURN_CODE=14;
                fi
            fi
        else
            ## we dont have a cert. error out and start over
            ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Generated certificate file is unusable. Please try again.";

            RETURN_CODE=16;
        fi
    else
        ## we werent given a cert. error
        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No certificate was found for ${SITE_DOMAIN_NAME}. Cannot continue.";

        RETURN_CODE=15;
    fi

    unset CERTIFICATE_DATABASE;
    unset CERTIFICATE_NICKNAME;
    unset SITE_DOMAIN_NAME;
    unset CERTIFICATE_EXPIRY;
    unset RET_CODE;
    unset RENEWED_CERTIFICATE_NICKNAME;
    unset RENEWED_CERT_EXPIRY;
    unset RET_CODE;
    unset MAILER_CODE;

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";
}

#===  FUNCTION  ===============================================================
#          NAME:  apply_cert
#   DESCRIPTION:  Copies the relevant certificate databases to each webnode in
#                 the affected cluster, and then executes the renewal executor
#                 to make changes effective.
#    PARAMETERS:  None
#       RETURNS:  0
#==============================================================================
function applyiPlanetCert
{
    [[ ! -z "${TRACE}" && "${TRACE}" = "${_TRUE}" ]] && set -x;
    local METHOD_NAME="${CNAME}#${0}";

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";

    WEB_INSTANCE_NAME=$(echo ${CERTIFICATE_DATABASE} | cut -d "-" -f 1-2);
    SERVER_LIST=$(getPlatformInfo | grep -w ${PLATFORM_CODE} | cut -d "|" -f 5 | sed -e "s/,/ /g");
    CERTIFICATE_NICKNAME=$(certutil -L -d ${APP_ROOT}/${CERTDB_STORE} -P ${CERTIFICATE_DATABASE} | grep "u,u,u" | awk '{print $1}');

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "WEB_INSTANCE_NAME -> ${WEB_INSTANCE_NAME}";
    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "SERVER_LIST -> ${SERVER_LIST}";
    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CERTIFICATE_NICKNAME -> ${CERTIFICATE_NICKNAME}";

    ## make sure both the certificate database and pkcs file exist
    if [ -s ${APP_ROOT}/${CERTDB_STORE}/${CERTIFICATE_DATABASE}${IPLANET_CERT_STORE_KEY_SUFFIX} ] \
        && [ -s ${APP_ROOT}/${CERTDB_STORE}/${CERTIFICATE_DATABASE}${IPLANET_CERT_STORE_CERT_SUFFIX} ]
    then
        if [ -s ${APP_ROOT}/${PKCS12STORE}/${CERTIFICATE_NICKNAME}.pkcs ]
        then
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Files validated. Processing renewal..";

            ## start the process
            if [ ! -z "${SERVER_LIST}" ]
            then
                for WEBSERVER in ${SERVER_LIST}
                do
                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Now operating against ${WEBSERVER}..";
                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Now validating access..";

                    $(ping ${WEBSERVER} > /dev/null 2>&1);
                    PING_RCODE=${?}

                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PING_RCODE -> ${PING_RCODE}";

                    if [ ${PING_RCODE} == 0 ]
                    then
                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Submitting files to ${WEBSERVER}..";

                        REMOTE_CERT_DB=$(echo ${CERTIFICATE_DATABASE} | sed -e "s/${IUSER_AUDIT}/${WEBSERVER}/");

                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "REMOTE_CERT_DB -> ${REMOTE_CERT_DB}";

                        for SUFFIX in ${IPLANET_CERT_STORE_KEY_SUFFIX} ${IPLANET_CERT_STORE_CERT_SUFFIX}
                        do
                            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command runSCPConnection.exp local-copy ${WEBSERVER} ${APP_ROOT}/${CERTDB_STORE}/${CERTIFICATE_DATABASE}${SUFFIX} ${APP_ROOT}/${CERTDB_STORE}/${REMOTE_CERT_DB}${SUFFIX} ${IPLANET_OWNING_USER};";

                            ${APP_ROOT}/lib/tcl/runSCPConnection.exp local-copy ${WEBSERVER} \
                                ${APP_ROOT}/${CERTDB_STORE}/${CERTIFICATE_DATABASE}${SUFFIX} \
                                ${APP_ROOT}/${CERTDB_STORE}/${REMOTE_CERT_DB}${SUFFIX} ${IPLANET_OWNING_USER};
                        done

                        ## copy up the pkcs file
                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command runSCPConnection.exp local-copy ${WEBSERVER} ${APP_ROOT}/${PKCS12STORE}/${CERTIFICATE_NICKNAME}.pkcs ${APP_ROOT}/${PKCS12STORE}/${CERTIFICATE_NICKNAME}.pkcs ${IPLANET_OWNING_USER}";

                        ${APP_ROOT}/lib/tcl/runSCPConnection.exp local-copy ${WEBSERVER} \
                            ${APP_ROOT}/${PKCS12STORE}/${CERTIFICATE_NICKNAME}.pkcs \
                            ${APP_ROOT}/${PKCS12STORE}/${CERTIFICATE_NICKNAME}.pkcs ${IPLANET_OWNING_USER};

                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "File copies complete. Continuing..";
                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command ${APP_ROOT}/lib/tcl/runSSHConnection.exp ${WEBSERVER} ${REMOTE_APP_ROOT}/lib/executors/executeCertRenewal.sh -w ${WEB_INSTANCE_NAME} -p ${WEBSERVER_PLATFORM} -r ${ENVIRONMENT_TYPE} -d ${REMOTE_CERT_DB} -n ${CERTIFICATE_NICKNAME} -i ${IUSER_AUDIT} -c ${CHANGE_NUM} -e ${IPLANET_OWNING_USER}";

                        ## ok, files copied, run the executor
                        ${APP_ROOT}/lib/tcl/runSSHConnection.exp ${WEBSERVER} "${APP_ROOT}/lib/executors/executeCertRenewal.sh -w ${WEB_INSTANCE_NAME} -p ${WEBSERVER_PLATFORM} -r ${ENVIRONMENT_TYPE} -d ${REMOTE_CERT_DB} -n ${CERTIFICATE_NICKNAME} -i ${IUSER_AUDIT} -c ${CHANGE_NUM} -e" ${IPLANET_OWNING_USER};
                        RENEWAL_CODE=${?};

                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RENEWAL_CODE -> ${RENEWAL_CODE}";

                        if [ ${RENEWAL_CODE} != 0 ]
                        then
                            ## error
                            ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "An error occurred performing the renewal against ${WEBSERVER}. Please try again.";

                            (( ERROR_COUNT += 1 ));
                        else
                            ${LOGGER} AUDIT "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate Renewal (implementation) by ${IUSER_AUDIT}: Webserver: ${WEBSERVER}; Site: ${SITE_DOMAIN_NAME}; Certificate Database: ${CERTIFICATE_DATABASE}; Certificate Nickname: ${CERTIFICATE_NICKNAME}";
                        fi
                    else
                        ## ping test failure
                        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${WEBSERVER} appears unavailable. PING_RCODE -> ${PING_RCODE}";

                        (( ERROR_COUNT += 1 ));
                    fi
                done

                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "ERROR_COUNT -> ${ERROR_COUNT}";

                if [ ${ERROR_COUNT} == 0 ]
                then
                    ## successful implementation
                    ## create a backup of the existing files, then clean up
                    ${LOGGER} AUDIT "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate Renewal (implementation) by ${IUSER_AUDIT}: Site: ${SITE_DOMAIN_NAME}; Certificate Database: ${CERTIFICATE_DATABASE}; Certificate Nickname: ${CERTIFICATE_NICKNAME}";

                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Implementation complete. Backing up files..";

                    BACKUP_TARFILE=${APP_ROOT}/${BACKUP_DIRECTORY}/${CERTIFICATE_NICKNAME}-${IUSER_AUDIT}-${CHANGE_NUM}-$(date +"%Y-%m-%d").tar.gz;

                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "BACKUP_TARFILE -> ${BACKUP_TARFILE}";

                    (tar cf - ${APP_ROOT}/${CERTDB_STORE}/${CERTIFICATE_DATABASE}* \
                        ${APP_ROOT}/${PKCS12STORE}/${CERTIFICATE_NICKNAME}.pkcs \
                        ${APP_ROOT}/${CSRSTORE}/${CERT_NICKNAME}.csr \
                        ${APP_ROOT}/${PEMSTORE}/${CERTIFICATE_NICKNAME}.pem \
                        ${APP_ROOT}/${CERTSTORE}/${CERTIFICATE_NICKNAME}.cer) | gzip -c > ${BACKUP_TARFILE};

                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backup complete. Validating..";

                    if [ -s ${BACKUP_TARFILE} ]
                    then
                        ## backup complete
                        ## remove temp files
                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Backup validated. Removing working files..";

                        rm -rf ${APP_ROOT}/${PKCS12STORE}/${CERTIFICATE_NICKNAME}.pkcs ${APP_ROOT}/${CSRSTORE}/${CERT_NICKNAME}.csr \
                            ${APP_ROOT}/${PKCS12STORE}/${CERTIFICATE_NICKNAME}.pkcs ${APP_ROOT}/${PEMSTORE}/${CERTIFICATE_NICKNAME}.pem \
                            ${APP_ROOT}/${CERTSTORE}/${CERTIFICATE_NICKNAME}.cer ${APP_ROOT}/${CERTDB_STORE}/${CERTIFICATE_DATABASE}* > /dev/null 2>&1;

                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Process complete.";

                        RETURN_CODE=0;
                    else
                        ${LOGGER} "WARN" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "An error occurred generating the backup file. Please process manually.";

                        RETURN_CODE=94;
                    fi
                else
                    ## error occured
                    ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "One or more errors occurred during the renewal process. Cannot continue.";

                    RETURN_CODE=49;
                fi
            else
                ## target server list is empty
                ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Server list generation has failed. Please ensure that the proper arguments were provided and try again.";

                RETURN_CODE=29;
            fi
        else
            ## pkcs file doesnt exist
            ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No PKCS file exists. Please ensure that the certificate has been exported and try again.";

            RETURN_CODE=30;
        fi
    else
        ## certificate databases dont exist
        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No certificate databases were found for this renewal. Please try again.";

        RETURN_CODE=6;
    fi

    unset RENEWAL_CODE;
    unset SUFFIX;
    unset REMOTE_CERT_DB;
    unset PING_RCODE;
    unset WEBSERVER;
    unset SERVER_LIST;
    unset CERTIFICATE_NICKNAME;
    unset WEB_INSTANCE_NAME;

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";
}

#===  FUNCTION  ===============================================================
#          NAME:  generateAndApplySelfSignedCert
#   DESCRIPTION:  Provide information on the usage of this application
#    PARAMETERS:  None
#       RETURNS:  0
#==============================================================================
function generateAndApplySelfSignedCert
{
    [[ ! -z "${TRACE}" && "${TRACE}" = "${_TRUE}" ]] && set -x;
    local METHOD_NAME="${CNAME}#${0}";

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";

    if [ -s ${APP_ROOT}/${CSRSTORE}/SS-${CERT_NICKNAME}.csr ]
    then
        ## great. generate the cert
        openssl ca -batch -config ${OPENSSL_CONFIG_FILE} -policy policy_anything \
            -out ${APP_ROOT}/${CERTSTORE}/SS-${CERT_NICKNAME}.cer -infiles ${APP_ROOT}/${CSRSTORE}/SS-${CERT_NICKNAME}.csr \
            1>${LOG_ROOT}/openssl-out.log 2>${LOG_ROOT}/openssl-error.log;
        RET_CODE=${?};

        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";

        if [ ! -z "${RET_CODE}" ]
        then
            if [ ${RET_CODE} == 0 ]
            then
                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Validating certificate creation..";

                if [ -s ${APP_ROOT}/${CERTSTORE}/SS-${CERT_NICKNAME}.cer ]
                then
                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate created. Re-distributing text..";

                    ## xlnt. re-distribute the text
                    sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' ${APP_ROOT}/${CERTSTORE}/SS-${CERT_NICKNAME}.cer \
                        > ${APP_ROOT}/${CERTSTORE}/SS-${CERT_NICKNAME}.cer.tmp;

                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Distribution complete. Validating..";

                    if [ -s ${APP_ROOT}/${CERTSTORE}/SS-${CERT_NICKNAME}.cer.tmp ]
                    then
                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "File created. Validating text..";

                        if [ $(grep -c "BEGIN CERTIFICATE" ${APP_ROOT}/${CERTSTORE}/SS-${CERT_NICKNAME}.cer.tmp) != 0 ] \
                            && [ $(grep -c "END CERTIFICATE" ${APP_ROOT}/${CERTSTORE}/SS-${CERT_NICKNAME}.cer.tmp) != 0 ]
                        then
                            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Text validated. Moving file..";

                            ## cert is valid, move it
                            mv ${APP_ROOT}/${CERTSTORE}/SS-${CERT_NICKNAME}.cer.tmp ${APP_ROOT}/${CERTSTORE}/SS-${CERT_NICKNAME}.cer > /dev/null 2>&1;

                            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Move complete. Validating..";

                            if [ -s ${APP_ROOT}/${CERTSTORE}/SS-${CERT_NICKNAME}.cer ]
                            then
                                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "File created, validating..";

                                if [ $(grep -c "BEGIN CERTIFICATE" ${APP_ROOT}/${CERTSTORE}/SS-${CERT_NICKNAME}.cer) != 0 ] \
                                    && [ $(grep -c "END CERTIFICATE" ${APP_ROOT}/${CERTSTORE}/SS-${CERT_NICKNAME}.cer) != 0 ]
                                then
                                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Validation complete. Applying certificate..";
                                    ## good. now import the new
                                    unset RET_CODE;

                                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Executing command certutil -d ${APP_ROOT}/${CERTDB_STORE} -A -i ${APP_ROOT}/${CERTSTORE}/SS-${CERT_NICKNAME}.cer -n ${CERT_NICKNAME} -t \"u,u,u\"  -P ${CERTIFICATE_DATABASE}..";

                                    certutil -d ${APP_ROOT}/${BUILD_TMP_DIR}/${IUSER_AUDIT}/${IPLANET_CERT_DIR} -A -i ${APP_ROOT}/${CERTSTORE}/SS-${CERT_NICKNAME}.cer -n ${CERT_NICKNAME} -t "u,u,u"  -P ${CERTIFICATE_DATABASE} >> ${APP_ROOT}/${LOG_ROOT}/certutil.${SITE_DOMAIN_NAME}.${IUSER_AUDIT} 2>&1;
                                    RET_CODE=${?};

                                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "RET_CODE -> ${RET_CODE}";

                                    if [ ${RET_CODE} != 0 ]
                                    then
                                        ## an error occurred importing the cert
                                        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "An error occurred during keystore certificate renewal. Cannot continue.";

                                        RETURN_CODE=17;
                                    else
                                        ## export it out for import into crypto
                                        ## some boxes might not have crypto. we dont
                                        ## care at this point, but the executor will.
                                        ${LOGGER} AUDIT "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Self-signed certificate successfully applied to ${CERTIFICATE_DATABASE} for ${CERT_NICKNAME}";

                                        RETURN_CODE=0;
                                    fi
                                else
                                    ## move completed, but certificate doesnt exist
                                    ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Unable to confirm that certificate file is valid. Please try again.";

                                    RETURN_CODE=19;
                                fi
                            else
                                ## move failed
                                ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Failed to create certificate file. Please try again.";

                                RETURN_CODE=19;
                            fi
                        else
                            ## file created, but data doesnt exist
                            ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Unable to confirm that certificate file is valid. Please try again.";

                            RETURN_CODE=19;
                        fi
                    else
                        ## file wasnt created
                        ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No certificate file was generated. Please try again.";

                        RETURN_CODE=19;
                    fi
                else
                    ## zero return code but no pkcs file. no good
                    ## this might be non-fatal, if the environment
                    ## being applied to doesnt have a crypto card
                    ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Certificate successfully renewed against database files, but pkcs file for metaslot failed to generate. Please try again.";

                    RETURN_CODE=13;
                fi
            fi
        else
            ## cert imported didnt match what we were expecting. error out
            ## TODO: maybe start over ?
            ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Return code from OpenSSL was null. Please try again.";

            RETURN_CODE=14;
        fi
    fi

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";
}

#===  FUNCTION  ===============================================================
#          NAME:  usage
#   DESCRIPTION:  Provide information on the usage of this application
#    PARAMETERS:  None
#       RETURNS:  0
#==============================================================================
function usage
{
    [[ ! -z "${TRACE}" && "${TRACE}" = "${_TRUE}" ]] && set -x;
    local METHOD_NAME="${CNAME}#${0}";

    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> enter";

    print "${CNAME} - Apply a new SSL certificate to a secure site instance";
    print "Usage: ${CNAME} [ -d certificate database ] [ -s site hostname ] [ -w webserver platform ] [ -p platform code ] [ -c change request ] [ -a ] [-e] [-?|-h]";
    print "  -d      The certificate database to apply changes to, e.g. https-site.name_project-hostname-";
    print "  -s      The relevant site hostname, e.g. site.name.com";
    print "  -w      The webserver platform type associated with this website.";
    print "  -p      The associated platform code.";
    print "  -S      Indicates that this is a self-signed certificate";
    print "  -c      The change order associated with this request";
    print "  -a      Commit changes to relevant webservers";
    print "  -e      Execute processing";
    print "  -?|-h   Show this help";

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

while getopts ":d:s:w:p:c:Saeh:" OPTIONS
do
    case "${OPTIONS}" in
        d)
            ## set the certificate database name
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting CERTIFICATE_DATABASE..";

            ## Capture the site root
            CERTIFICATE_DATABASE=${OPTARG};

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CERTIFICATE_DATABASE -> ${CERTIFICATE_DATABASE}";
            ;;
        s)
            ## set the site hostname
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting SITE_DOMAIN_NAME..";

            ## Capture the site root
            SITE_DOMAIN_NAME=${OPTARG};

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "SITE_DOMAIN_NAME -> ${SITE_DOMAIN_NAME}";
            ;;
        w)
            ## set the platform
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting WS_PLATFORM..";

            ## Capture the site root
            WS_PLATFORM=${OPTARG};

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "WS_PLATFORM -> ${WS_PLATFORM}";
            ;;
        p)
            ## set the platform code
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting PLATFORM_CODE..";

            ## Capture the site root
            typeset -u PLATFORM_CODE="${OPTARG}";

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "PLATFORM_CODE -> ${PLATFORM_CODE}";
            ;;
        S)
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting SELF_SIGNED..";

            ## Capture the site root
            SELF_SIGNED=${_TRUE};

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "SELF_SIGNED -> ${SELF_SIGNED}";
            ;;
        c)
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting CHANGE_NUM..";

            ## Capture the change control
            typeset -u CHANGE_NUM="${OPTARG}";

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CHANGE_NUM -> ${CHANGE_NUM}";
            ;;
        a)
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting CLUSTER_APPLICATION to ${_TRUE}..";

            ## Capture the change control
            CLUSTER_APPLICATION=${_TRUE};

            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CLUSTER_APPLICATION -> ${CLUSTER_APPLICATION}";
            ;;
        e)
            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Validating request..";

            ## Make sure we have enough information to process
            ## and execute
            if [ -z "${RETURN_CODE}" ]
            then
                if [ -z "${CERTIFICATE_DATABASE}" ]
                then
                    ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No certificate database was provided. Cannot continue.";
                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                    RETURN_CODE=9;
                elif [ -z "${SITE_DOMAIN_NAME}" ]
                then
                    ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No site domain name was provided. Unable to continue processing.";
                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                    RETURN_CODE=11;
                elif [ -z "${WS_PLATFORM}" ]
                then
                    ## no webserver platform type received
                    ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No webserver platform was provided. Unable to continue processing.";
                    [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                    RETURN_CODE=21;
                else
                    if [ ! -z "${CLUSTER_APPLICATION}" ] && [ "${CLUSTER_APPLICATION}" = "${_TRUE}" ]
                    then
                        if [ -z "${CHANGE_NUM}" ]
                        then
                            ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No change order was provided. Unable to continue processing.";
                            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                            RETURN_CODE=12;
                        elif [ -z "${PLATFORM_CODE}" ]
                        then
                            ## no platform code received
                            ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No platform code was provided. Unable to continue processing.";
                            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                            RETURN_CODE=25;
                        else
                            [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                            if [ "${WS_PLATFORM}" = "${IPLANET_TYPE_IDENTIFIER}" ]
                            then
                                applyiPlanetCert;
                            elif [ "${WS_PLATFORM}" = "${IHS_TYPE_IDENTIFIER}" ]
                            then
                                applyIHSCert;
                            else
                                ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No valid webserver platform was provided. Cannot continue.";
                                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                RETURN_CODE=999;
                            fi
                        fi
                    else
                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Request validated - executing";
                        [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                        if [ ! -z "${SELF_SIGNED}" ] && [ "${SELF_SIGNED}" = "${_TRUE}" ]
                        then
                            generateAndApplySelfSignedCert;
                        else
                            if [ "${WS_PLATFORM}" = "${IPLANET_TYPE_IDENTIFIER}" ]
                            then
                                renewiPlanetCert;
                            elif [ "${WS_PLATFORM}" = "${IHS_TYPE_IDENTIFIER}" ]
                            then
                                renewIHSCert;
                            else
                                ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "No valid webserver platform was provided. Cannot continue.";
                                [[ ! -z "${VERBOSE}" && "${VERBOSE}" = "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME} -> exit";

                                RETURN_CODE=999;
                            fi
                        fi
                    fi
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
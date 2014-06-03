#!/usr/bin/env ksh
#==============================================================================
#
#          FILE:  backup_dir_cleanup.sh
#         USAGE:  ./add_indicators.sh
#   DESCRIPTION:  Adds and updates various indicators utilized by named, as
#                 well as adding auditory information.
#
#       OPTIONS:  ---
#  REQUIREMENTS:  ---
#          BUGS:  ---
#         NOTES:  ---
#        AUTHOR:  $Author$
#       COMPANY:  CaspersBox Web Services
#       VERSION:  $Revision$
#       CREATED:  $Date$
#      REVISION:  ---
#==============================================================================
## Application constants
[ -z "${PLUGIN_NAME}" ] && PLUGIN_NAME="WebAdministration";
CNAME="$(basename "${0}")";
SCRIPT_ABSOLUTE_PATH="$(cd "${0%/*}" 2>/dev/null; echo "${PWD}"/"${0##*/}")";
SCRIPT_ROOT="$(dirname "${SCRIPT_ABSOLUTE_PATH}")";

#===  FUNCTION  ===============================================================
#          NAME:  add_indicators
#   DESCRIPTION:  Searches for and replaces audit indicators for the provided
#                 filename.
#    PARAMETERS:  Parameters obtained via command-line flags
#       RETURNS:  0 for positive result, >1 for non-positive
#==============================================================================
function cleanup_filesystems
{
    [[ ! -z "${TRACE}" && "${TRACE}" = "${_TRUE}" ]] && set -x;
    local METHOD_NAME="${CNAME}#${0}";

    [[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME}->enter";
    [[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "TIMESPAN->${ZONE_ROOT}";
	[[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "IUSER_AUDIT->${IUSER_AUDIT}";
    [[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Cleaning up backup directories..";

    for FILENAME in $(find ${APP_ROOT}/${BACKUP_DIRECTORY} -type f -mtime +${TIMESPAN})
    do
        [[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Cleaning ${APP_ROOT}/${BACKUP_DIRECTORY}..";
        [[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "FILENAME->${FILENAME}";

        ${LOGGER} AUDIT "${METHOD_NAME}" "${CNAME}" "${LINENO}" "File ${APP_ROOT}/${BACKUP_DIRECTORY}/${FILENAME} removed on $(date +"%m-%d-%Y") by ${IUSER_AUDIT}";
        rm ${APP_ROOT}/${BACKUP_DIRECTORY}/${FILENAME};
    done

    if [ ${CLEAN_NAMED} ]
    then
        ## unset FILENAME
        unset FILENAME;

        for FILENAME in $(find ${NAMED_ROOT}/${NAMED_BACKUP_DIRECTORY} -type f -mtime +${TIMESPAN})
        do
            [[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Cleaning ${NAMED_ROOT}/${NAMED_BACKUP_DIRECTORY}..";
            [[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "FILENAME->${FILENAME}";

            ${LOGGER} AUDIT "${METHOD_NAME}" "${CNAME}" "${LINENO}" "File ${NAMED_ROOT}/${NAMED_BACKUP_DIRECTORY}/${FILENAME} removed on \`date +"%m-%d-%Y"\` by ${IUSER_AUDIT}";
            rm ${NAMED_ROOT}/${NAMED_BACKUP_DIRECTORY}/${FILENAME};
        done
    fi

    ## unset variables
	unset TIMESPAN;
	unset FILENAME;

    [[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME}->exit";

    RETURN_CODE=0;
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

    [[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME}->enter";

    print "${CNAME} - Add audit indicators and other flags to the failover zone file";
    print "Usage: ${CNAME} [-r ZONE_ROOT] [-f filename] [-t target datacenter] [-i requestor] [-c change request] [-e execute] [-?|-h show this help]";
    print "  -t      Timespan to clean. Default of 30 days.";
    print "  -i      The user performing the request";
    print "  -n      Clean the named backup directory as well as the application backup directory.";
    print "  -e      Execute processing";
    print "  -h|-?   Show this help";

    [[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME}->exit";

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

while getopts ":t:i:neh:" OPTIONS
do
    case "${OPTIONS}" in
        t)
            [[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting TIMESPAN..";

            if [ -z ${OPTARG} ]
            then
                [[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Timespan argument not provided. Defaulting to 30";
                TIMESPAN=30;
            else
                TIMESPAN=${OPTARG};
            fi

            [[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "TIMESPAN -> ${TIMESPAN}";
            ;;
        i)
            [[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting IUSER_AUDIT..";

            ## Capture the username
            IUSER_AUDIT="${OPTARG}";

            [[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "IUSER_AUDIT -> ${IUSER_AUDIT}";
            ;;
        n)
            [[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "OPTARG -> ${OPTARG}";
            [[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Setting CLEAN_NAMED..";

            ## Capture the username
            CLEAN_NAMED=${_TRUE};

            [[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "CLEAN_NAMED -> ${CLEAN_NAMED}";
            ;;
        e)
            [[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Validating request..";

            ## Make sure we have enough information to process
            ## and execute
            if [ -z "${IUSER_AUDIT}" ]
            then
                ${LOGGER} "ERROR" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "The requestors username was not provided. Unable to continue processing.";
                [[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME}->exit";

                RETURN_CODE=20;
            else
                ## We have enough information to process the request, continue
                [[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "Request validated - executing";
                [[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME}->exit";

                cleanup_filesystems;
            fi
            ;;
        h)
            [[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME}->exit";

            usage;
            ;;
        [\?])
            [[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME}->exit";

            usage;
            ;;
        *)
            [[ ! -z ${VERBOSE} && "${VERBOSE}" == "${_TRUE}" ]] && ${LOGGER} "DEBUG" "${METHOD_NAME}" "${CNAME}" "${LINENO}" "${METHOD_NAME}->exit";

            usage;
            ;;
    esac
done

shift ${OPTIND}-1;

echo ${RETURN_CODE};
return ${RETURN_CODE};
#!/bin/bash

config="./project_builder.conf"

error(){
	printf "\033[35mError:\t\033[31m${1}!\033[0m\n"
	exit 1
}

[ ! -f "${config}" ] && error "Missing ${config} file not found"
source ${config}

if [ ! -z "${companyName}" -a ! -z "${appName}" ];
then
	groupId="com.${companyName}.${appName}"
else
	error "Missing 'companyName' or 'appName' parameter"
fi

if [ ! -z "${artifactId}" ];
then
	artifactId="${artifactId}"
else
	error "Missing 'artifact' parameter"
fi

if [ ! -z "${archetypeArtifactId}" ];
then
	archetypeArtifactId="${archetypeArtifactId}"
else
	error "Missing 'archetypeArtifactId' parameter"
fi

# Example:
# mvn archetype:generate -DgroupId=com.mycompany.app -DartifactId=my-app -DarchetypeArtifactId=maven-archetype-quickstart \
# -DarchetypeVersion=1.4 -DinteractiveMode=false
build(){
	mvn archetype:generate -DgroupId=${groupId} -DartifactId=${artifactId} -DarchetypeArtifactId=${archetypeArtifactId} \
	-DarchetypeVersion=1.4 -DinteractiveMode=false
}

flush(){
	app_name=${1}
	if [ -d "${app_name}" ];
	then
		printf "Removing application. "
		read -p "Are you sure? [yes|no] " _confirm
		case $_confirm in
			y|yes)
			if [ -d "${app_name}" ];
			then
				rm -rfv "${app_name}"
			fi
			;;
			n|no) printf "Nothing executed, exiting program";;
		esac
	else
		printf "\033[35mNo application \033[33m${app_name}\033[0m \033[35mavailable.\033[0m\n"
	fi
}

usage(){
		printf "\033[36mUSAGE:\033[0m\n"
		printf "\033[35m$0\t\033[32m--exec=\033[33mCOMMAND\033[0m\n"
		printf "\033[35m$0\t\033[32m--exec=\033[33mCOMMAND\033[0m --app=\033[33mAPP_NAME\033[0m\n"
}

command(){
	printf "\033[36mCOMMAND:\033[0m\n"
	printf "\033[36mBuild Application: \033[33mbuild\033[0m\n"
	printf "\033[36mFlush Application: \033[33mflush\033[0m\n"

}

help_menu(){
	printf "\033[36mProject Builder\033[0m\n"
	printf "\033[35mExecute a command\t\033[32m[ exec ]\033[0m\n"
	printf "\033[35mFlush Selected App\t\033[32m[ flush ]\033[0m\n"
	printf "\033[35mView Help Menu\t\t\033[32m[ help ]\033[0m\n"
	command
	usage
	exit 0
}

for arg in $@
do
	case $arg in
		--exec=*|exec:*) _exec=$(echo "${arg}" | cut -d'=' -f2);;
		--app=*|app:*) _appname=$(echo "${arg}" | cut -d'=' -f2);;
		-h|-help|--help) help_menu;;
	esac
done

case $_exec in
	build) build;;
	flush)
	if [ ! -z "${_appname}" ];
	then
		flush ${_appname}
	else
		error "Missing or invalid application name was given"
	fi
	;;
esac

#!/bin/bash
FLAG_DRY_RUN=0

usage() {
    echo "$0 -c CONFIG_FILE -l LIST_FILE [-s server_name] [-h]"
    exit 0
}

while getopts "c:dl:s:h" OPT
do
    case $OPT in
        c)
	    ENABLE_c="t"
            if [ -f $OPTARG ]; then
                echo "CONFIG  : $OPTARG" 
		CONF_FILE=$OPTARG
		source $OPTARG
            else
                usage
            fi
            ;;
        d)
            echo "INFO    : DRYRUN" 
            FLAG_DRY_RUN=1
            ;;
        l)
	    ENABLE_l="t"
            if [ -f $OPTARG ]; then
                echo "LIST    : $OPTARG"
                GIT_REPO_LIST=$OPTARG
            else
                usage
            fi
            ;;
        s)  
            SERVER_OVERRIDE=$OPTARG
            ;;
        h) usage
            ;;
        *) usage
            ;;
    esac
done
shift $((OPTIND - 1))

# Checking for reuired options (c and l) 
[ "${ENABLE_c}" != "t" ] && usage
[ "${ENABLE_l}" != "t" ] && usage

# cut -f1 -d' ' $GIT_REPO_LIST | sort | uniq > $GIT_REPO_LIST_UNIQ
if [ ! -f $GIT_REPO_LIST ]; then
    echo "ERROR   : $GIT_REPO_LIST does not exist"
    exit 1
fi

if [ ! -d $GIT_BASE_DIR ]; then
    echo "ERROR   : $GIT_BASE_DIR does not exist"
    exit 1
fi

while read line;do
    cd $GIT_BASE_DIR
    REPO=${line}
    if [[ $REPO =~ ^# ]]; then
	echo "INFO    : SKIP $REPO"
	continue
    fi
    REPO_DIR=$REPO.git
    echo "REPO_DIR: $REPO_DIR"
    if [ ! -d $REPO_DIR ]
    then
        echo "INFO    : MIRROR $GIT_SERVER/$REPO_DIR"
        if [ $FLAG_DRY_RUN -ne 0 ]; then
	    echo "DRYRUN  : git clone --mirror $GIT_SERVER/$REPO_DIR"
        else
	    echo -n "INFO    : "
	    git clone --mirror $GIT_SERVER/$REPO_DIR
        fi
    else
        cd $REPO_DIR
        echo "INFO    : FETCH $GIT_SERVER/$REPO_DIR"
        if [ $FLAG_DRY_RUN -ne 0 ]; then
	    echo "DRYRUN  : git fetch --all"
        else
	    echo -n "INFO    : "
            git fetch --all
        fi
    fi
done < $GIT_REPO_LIST

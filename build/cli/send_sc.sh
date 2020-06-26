#!/bin/bash

WDIR=$PWD
QSCRIPT_FILE=$WDIR/tmpl/qscript
CL_FILE=$WDIR/tmpl/ir5.json
echo $WDIR

if [ ! -e "$CL_FILE" ] ; then
    echo "Missing cluster config file"
    exit 1
fi
if [ ! -e "$QSCRIPT_FILE" ] ; then
    echo "Missing qscript template file"
    exit 1
fi

# The first parameter passed to the script is taken as the
# subpath containing the VASP input files
SUBPATH=$1
if [ ! "$SUBPATH" ] ; then
    echo "Missing entry folder $SUBPATH"
    exit 1
fi

if [ "$2" ] ; then
    JOB_NAME="$2"
else
    # If not given use folder name
    JOB_NAME=$(basename $SUBPATH)
fi

if [ "$2" ] ; then
    WALLTIME="$3"
else
    # If not give set to max on Iridis5
    WALLTIME="48:00:00"
fi

# Calculate number of nodes (get_poscar_nnodes must be in the path)
NUM_NODES=$(get_poscar_nnodes.py $SUBPATH/POSCAR)

# Create a submit script and make sure it's executable
# Must a templated with right keywords
sed "s:\$NUM_NODES:$NUM_NODES:"  $QSCRIPT_FILE  > $SUBPATH/qscript
sed  -i "" -e "s:\$JOB_NAME:$JOB_NAME:" $SUBPATH/qscript
sed  -i "" -e "s/\$WALLTIME/$WALLTIME/" $SUBPATH/qscript
chmod u+x $SUBPATH/qscript

# Create cluster config file for vasprun suite
source $HOME/bin/read_json_keys.sh # Function to read simple json fields in bash
keys=( hpc_fld sub_cmd hostname env_setup )
read_json_keys $CL_FILE ${keys[@]}
# Get a suitable entrypoint for the calulculation run
entry_pt=$(dirname $SUBPATH | sed "s:$PWD/::") # relative path this dir, or full path if somewherelse
hpc_fld="$hpc_fld/$entry_pt" # Concatenate given entry point with this
echo "HPC entry point $hpc_fld"

# Create cluster config file
out_json="$SUBPATH/cl_conf.json"
echo -n "{"                             >$out_json
echo "\"hostname\": \"$hostname\","     >>$out_json
echo "\"hpc_fld\": \"$hpc_fld\","     >>$out_json
echo "\"sub_cmd\": \"$sub_cmd\","     >>$out_json
echo "\"env_setup\": \"$env_setup\""     >>$out_json
echo "}">>$out_json

# Move to location and send the run
cd $SUBPATH
send_vasprun.sh -c cl_conf.json
cd $WDIR

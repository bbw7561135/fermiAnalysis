#!/usr/bin/env bash

#clean up after yourself
rm -rf /scratch/$USER*
wait
sleep {0[sleep]:.2f}

#set up the tmpdir
NFSDIR=$PWD
TMPDIR="/scratch/$USER.$LSB_JOBID"
mkdir -p $TMPDIR
sleep {0[extrasleep]:.2f}
wait

#make sure that tmpdir was set up correctly
i=0
ls $TMPDIR 1>&2
while [ $? -ne 0 -a $i -lt 10 ]; do 
    mkdir -p $TMPDIR
    sleep {0[sleep]:.2f}
    wait
    let "i++"
    ls $TMPDIR 1>&2
done

sleep {0[sleep]:.2f}
wait

ulimit -c 0        # disable core dump
wait

export HOME=$TMPDIR
i=0

# copy config file and script to cluster
#cp {0[config]:s} $TMPDIR
#sleep {0[sleep]:.2f}
#wait
#cp {0[script]:s} $TMPDIR

# if it didn't work, try it for 10 times
#while [ $? -ne 0 -a $i -lt 10 ]; do 
#    cp {0[script]:s} {0[config]:s} $TMPDIR
#    LAST_CALL=$?
#    sleep {0[sleep]:.2f}
#    wait
#    let "i++"
#done

sleep {0[sleep]:.2f}
wait

echo "checking TMPDIR before python call" 1>&2
ls $TMPDIR 1>&2

echo "some additional info:" 1>&2
echo "HOST: $HOST" 1>&2
echo "PWD: $PWD" 1>&2
date 1>&2

cd $HOME

export MAX_JOB=$((LSB_JOBINDEX + LSB_JOBINDEX_STEP))
while [ $LSB_JOBINDEX -lt $MAX_JOB -a $LSB_JOBINDEX -le $LSB_JOBINDEX_END ]; do
    echo $MAX_JOB

#    echo "calling python: $TMPDIR/{0[scriptfile]:s} -c $TMPDIR/{0[configfile]:s} {0[add_opt]:s} 1> $TMPDIR/out.$LSB_JOBINDEX 2> $TMPDIR/err.$LSB_JOBINDEX" 1>&2
#    python $TMPDIR/{0[scriptfile]:s} -c $TMPDIR/{0[configfile]:s} {0[add_opt]:s} 1> $TMPDIR/out.$LSB_JOBINDEX 2> $TMPDIR/err.$LSB_JOBINDEX
    echo "calling python: {0[script]:s} -c {0[config]:s} {0[add_opt]:s} 1> $TMPDIR/out.$LSB_JOBINDEX 2> $TMPDIR/err.$LSB_JOBINDEX" 1>&2
    python {0[script]:s} -c {0[config]:s} {0[add_opt]:s} 1> $TMPDIR/out.$LSB_JOBINDEX 2> $TMPDIR/err.$LSB_JOBINDEX

    if [ $? -eq 0 ]; then
        echo python OK
    else
        #date 1>&2
        #echo "$LSB_JOBNAME $LSB_JOBID . $LSB_JOBINDEX python failed" 1>&2
        #echo "checking TMPDIR after failed python call" 1>&2
        #ls $TMPDIR 1>&2
        #sleep {0[sleep]:.2f}
        #wait

        #rsync {0[script]:s} $TMPDIR
        #sleep {0[sleep]:.2f}
        #wait

        #rsync {0[config]:s} $TMPDIR
        #sleep {0[sleep]:.2f}
        #wait

        #python $TMPDIR/{0[scriptfile]:s} -c $TMPDIR/{0[configfile]:s} {0[add_opt]:s} 1> $TMPDIR/out.$LSB_JOBINDEX 2> >(tee $TMPDIR/err.$LSB_JOBINDEX >&2)
        python {0[script]:s} -c {0[config]:s} {0[add_opt]:s} 1> $TMPDIR/out.$LSB_JOBINDEX 2> >(tee $TMPDIR/err.$LSB_JOBINDEX >&2)
    fi
    PYTHON_OK=$?

    sleep {0[sleep]:.2f}
    wait
    cp $TMPDIR/out.$LSB_JOBINDEX {0[logdir]:s}
    sleep {0[sleep]:.2f}
    wait
    cp $TMPDIR/err.$LSB_JOBINDEX {0[logdir]:s}
    sleep {0[sleep]:.2f}
    wait

    let "LSB_JOBINDEX++"

done
wait
sleep {0[sleep]:.2f}

cd $NFSDIR
rm -rf /scratch/$USER*
sleep {0[sleep]:.2f}
wait

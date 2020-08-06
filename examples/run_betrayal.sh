#!/bin/bash
echo
echo "################ PLEASE NOTE #################"
echo
echo "* The program may take several minutes to run. It is not optimized for performance yet."
echo "* You do not have to wait for the optimal answer"
echo "    - You can press Ctrl+C to stop the optimization once at least one answer set (list of predicates) has been printed"
sleep 2
echo
echo
echo "################ RUNNING betrayal.lp #################"
echo
CORES=$(grep -c ^processor /proc/cpuinfo)
if [ -z "$CORES" ]; then
    echo "Cannot detect number of CPU cores. Running with 4 threads."
    CORES=4
else
    echo "$CORES CPU cores detected. Running with $CORES threads."
    CORES=4
fi

echo
clingo ../cpocl.lp betrayal.lp -t $CORES | tee betrayal_output.txt

# Reverse the file to get the latest output. The output is the next line after "Optimization: XXX"
OUTPUT=$(tac betrayal_output.txt | grep "Optimization:" -A 2 -m 1 | sed '2q;d')
echo
echo
echo "################ VISUALIZATION #################"
if [ -z "$OUTPUT" ]; then
    echo
    echo "Could not find an answer in betrayal_output.txt. Perhaps the run was canceled too soon?"
    echo "Please wait for the planner to print at least one answer set (list of predicates) before pressing Ctrl+C"
else
    echo
    echo "Detected a generated answer set. Please copy the following:"
    echo
    echo
    echo $OUTPUT
    echo
    echo
    echo "Paste the above in the visualizer: https://csdabral-ncsu.github.io/asp_formatter/ to see the graph"
    echo
fi
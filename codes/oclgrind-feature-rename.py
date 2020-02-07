
import sys

assert(len(sys.argv) == 2),"not enough arguments"

def RenameAIWCMetrics(line):
    import re
    #drop "freedom to reorder" and "resource pressure" -- these need to be reimplemented
    line = "" if re.search("freedom to reorder",line) else line
    line = "" if re.search("resource pressure",line) else line

    #drop "operand sum", "granularity", "barriers per instruction" and "instructions per operand" -- these are derived metrics
    line = "" if re.search("operand sum",line) else line
    line = "" if re.search("granularity",line) else line
    line = "" if re.search("barriers per instruction",line) else line
    line = "" if re.search("instructions per operand",line) else line

    # TODO: where are "Unique Reads" "Unique Writes", "Unique Read/Write Ratio", "Total Reads", "Total Writes", "Rereads" and "Rewrites"?
    # and what are these: "total global memory accessed", "total local memory accessed", "total constant memory accessed", "relative local memory usage" and "relative constant memory usage"?
    line = "" if re.search("total global memory accessed",line) else line
    line = "" if re.search("total local memory accessed",line) else line
    line = "" if re.search("total constant memory accessed",line) else line
    line = "" if re.search("relative local memory usage",line) else line
    line = "" if re.search("relative constant memory usage",line) else line

    #rename the goodies -- and add the metric category
    line = re.sub("metric,count", "metric,category,count", line)
    line = re.sub("opcode", "Opcode,Compute", line)
    line = re.sub("total instruction count", "Total Instruction Count,Compute", line)
    line = re.sub("workitems", "Work-items,Parallelism", line)
    line = re.sub("total # of barriers hit", "Total Barriers Hit,Parallelism", line)
    line = re.sub("min instructions to barrier", "Min ITB,Parallelism", line)
    line = re.sub("max instructions to barrier", "Max ITB,Parallelism", line)
    line = re.sub("median instructions to barrier", "Median ITB,Parallelism", line)
    line = re.sub("min instructions executed by a work-item", "Min IPT,Parallelism", line)
    line = re.sub("max instructions executed by a work-item", "Max IPT,Parallelism", line)
    line = re.sub("median instructions executed by a work-item", "Median IPT,Parallelism", line)
    line = re.sub("max simd width", "Max SIMD Width,Parallelism", line)
    line = re.sub("mean simd width", "Mean SIMD Width,Parallelism", line)
    line = re.sub("stdev simd width", "SD SIMD Width,Parallelism", line)
    line = re.sub("total memory footprint", "Total Memory Footprint,Memory", line)
    line = re.sub("90% memory footprint", "90% Memory Footprint,Memory", line)
    line = re.sub("global memory address entropy", "Global Memory Address Entropy,Memory", line)
    line = re.sub("local memory address entropy -- 10 LSBs skipped","LMAE -- Skipped 10 LSBs,Memory", line)
    line = re.sub("local memory address entropy -- 1 LSBs skipped", "LMAE -- Skipped 1 LSBs,Memory", line)
    line = re.sub("local memory address entropy -- 2 LSBs skipped", "LMAE -- Skipped 2 LSBs,Memory", line)
    line = re.sub("local memory address entropy -- 3 LSBs skipped", "LMAE -- Skipped 3 LSBs,Memory", line)
    line = re.sub("local memory address entropy -- 4 LSBs skipped", "LMAE -- Skipped 4 LSBs,Memory", line)
    line = re.sub("local memory address entropy -- 5 LSBs skipped", "LMAE -- Skipped 5 LSBs,Memory", line)
    line = re.sub("local memory address entropy -- 6 LSBs skipped", "LMAE -- Skipped 6 LSBs,Memory", line)
    line = re.sub("local memory address entropy -- 7 LSBs skipped", "LMAE -- Skipped 7 LSBs,Memory", line)
    line = re.sub("local memory address entropy -- 8 LSBs skipped", "LMAE -- Skipped 8 LSBs,Memory", line)
    line = re.sub("local memory address entropy -- 9 LSBs skipped", "LMAE -- Skipped 9 LSBs,Memory", line)
    line = re.sub("parallel spatial locality -- 10 LSBs skipped","PSL -- Skipped 10 LSBs,Memory", line)
    line = re.sub("parallel spatial locality -- 0 LSBs skipped","PSL -- Skipped 0 LSBs,Memory", line)
    line = re.sub("parallel spatial locality -- 1 LSBs skipped","PSL -- Skipped 1 LSBs,Memory", line)
    line = re.sub("parallel spatial locality -- 2 LSBs skipped","PSL -- Skipped 2 LSBs,Memory", line)
    line = re.sub("parallel spatial locality -- 3 LSBs skipped","PSL -- Skipped 3 LSBs,Memory", line)
    line = re.sub("parallel spatial locality -- 4 LSBs skipped","PSL -- Skipped 4 LSBs,Memory", line)
    line = re.sub("parallel spatial locality -- 5 LSBs skipped","PSL -- Skipped 5 LSBs,Memory", line)
    line = re.sub("parallel spatial locality -- 6 LSBs skipped","PSL -- Skipped 6 LSBs,Memory", line)
    line = re.sub("parallel spatial locality -- 7 LSBs skipped","PSL -- Skipped 7 LSBs,Memory", line)
    line = re.sub("parallel spatial locality -- 8 LSBs skipped","PSL -- Skipped 8 LSBs,Memory", line)
    line = re.sub("parallel spatial locality -- 9 LSBs skipped","PSL -- Skipped 9 LSBs,Memory", line)
    line = re.sub("num unique memory addresses accessed", "# Unique Addresses Accessed,Memory",line)
    line = re.sub("num unique memory addresses read","# Unique Memory Addresses Read,Memory",line)
    line = re.sub("num unique memory addresses written","# Unique Memory Addresses Written,Memory",line)
    line = re.sub("unique read/write ratio","Unique Read/Write Ratio,Memory",line)
    line = re.sub("total reads","Total Reads,Memory",line)
    line = re.sub("total writes","Total Writes,Memory",line)
    line = re.sub("re-reads", "Reread Ratio,Memory", line)
    line = re.sub("re-writes", "Rewrite Ratio,Memory", line)
    line = re.sub("total unique branch instructions", "Total Unique Branch Instructions,Control", line)
    line = re.sub("90% branch instructions", "90% Branch Instructions,Control", line)
    line = re.sub("branch entropy \(yokota\)", "Yokota Branch Entropy,Control", line)
    line = re.sub("branch entropy \(average linear\)", "Average Linear Branch Entropy,Control", line)
    return(line)

content = []
with open(sys.argv[1],"r") as aiwc_file:
    print("Updating the AIWC feature names of file: "+sys.argv[1]+" to be consistent with thesis names...")
    for line in aiwc_file:
        content.append(RenameAIWCMetrics(line))
    print("Done.")

with open(sys.argv[1],"w") as aiwc_file:
    aiwc_file.writelines(content)

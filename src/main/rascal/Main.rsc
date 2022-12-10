module Main

import IO;

import lang::java::m3::Core;

M3 smallSqlModel = createM3FromDirectory(|project://SoftwareQualityManagement/smallsql/|);
M3 hsqldbModel = createM3FromDirectory(|project://SoftwareQualityManagement/hsqldb/|);

int main(int testArgument=0) {
    println("argument: <testArgument>");
    return testArgument;
}

M3 getSmallSqlModel() {
    return smallSqlModel;
}

M3 getHsqldbModel() {
    return hsqldbModel;
}
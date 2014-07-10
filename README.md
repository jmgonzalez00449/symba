This repository contains a [CMake](http://www.cmake.org) project for automatic compilation of
[Symba](https://bitbucket.org/arieg/ufo/src/popl14) and its dependencies.

## Compilation Instructions

1. Create a build sub-directory

        cd symba && mkdir build

2. Configure the build using cmake. Requires CMake version 2.8.11 or greater.

        cd build && cmake -DCMAKE_BUILD_TYPE=Release -DWITH_APRON=ON -DWITH_SOPLEX=ON ../

3. Download `soplex-1.7.1.tgz from`
   [here](http://soplex.zib.de/download.php?fname=soplex-1.7.1.tgz)
   and copy it to `symba/soplex/soplex-1.7.1.tgz`

4. Build. This downloads and compiles necessary dependencies.

        make

5. Symba executable is installed at `symba/build/ufo-prefix/bin`


## Running Symba

Parameters taken by Symba:

        ./symba [OPTIONS]

        OPTIONS:

          -b=<filename>               - Path to benchmark file

          -help                       - Display available options (-help-hidden for more)

          -lp-solver                  - Choose Linear Programming Solver
            =GLPK                     -   GLPK
            =SOPLEX                   -   SoPlex
        
          -opti-z3                    - Use Opt-Z3 in SymbaIR
            =true
            =false

          -split-temp                 - Solve objectives seperately (SymbaOneObj if false)
            =true
            =false

          -symba-alg                  - Algorithms to use
            =SYMB                     -   Symba
            =DNFB                     -   Linear Search using Apron
            =LPB                      -   Linear Search using Linear Programming Libs
            =OPT                      -   Linear Search using Opt-Z3

          -symba-pref-int             - Round towards integers (SymbaIROFF if false)
            =true
            =false

          -tpush-time=<number>        - Term push time limit (0.0,1.0] (balance parameter described in the paper)

Some examples on how to run Symba. All paths are relative to
`symba/build/ufo-prefix/src/ufo`

1. Symba(100). This is the default. Run on file "test/SMT-lib/ex1.smt2":

        ./symba -b=test/SMT-lib/ex1.smt2

2. SymbaOneObj. Optimize a single objective at a time. No information sharing.

        ./symba -b=test/SMT-lib/ex1.smt2 -split-temp=true

3. Symba(40) + Opt-Z3. Our best configuration on the bench set. balance set to 40 and uses Opt-Z3.

        ./symba -b=test/SMT-lib/ex1.smt2 -tpush-time=0.4 -opti-z3=true

4. LS(Opt-Z3). Linear search algorithm using Opt-Z3.

        ./symba -b=test/SMT-lib/ex1.smt2 -symba-alg=OPT

5. LS(GLPK). Linear search algorithm using GLPK.

        ./symba -b=test/SMT-lib/ex1.smt2 -symba-alg=LPB -lp-solver=GLPK

6. LS(SoPlex). Linear search algorithm using SoPlex.

        ./symba -b=test/SMT-lib/ex1.smt2 -symba-alg=LPB -lp-solver=SOPLEX
        
## Benchmarks for Symba

We generated 1,000+ benchmarks for Symba from the SV-COMP-13 software verification tasks.
The benchmark files can be found at [here](https://bitbucket.org/liyi0630/symba-bench).

## Questions

Contact [Arie Gurfinkel](http://arieg.bitbucket.org).

        


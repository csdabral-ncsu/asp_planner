## ASP Planner

### Requirements
* Requires clingo: https://github.com/potassco/clingo/releases

### Running the examples
Running an example requires 3 steps:
* Running clingo to generate answer sets
* Copying one of the answer sets
* Pasting the answer set into the visualization tool: https://csdabral-ncsu.github.io/asp_formatter/

#### Tested on Ubuntu:
*   ```
    $ cd examples/
    $ ./run_<example_name>.sh
    ```
* You do not have to wait for the optimization process to finish:
    * Each answer set generated is valid; optimization just removes unneeded causal ordering
    * Once at least one answer set has been printed, you may press Ctrl+C to stop further optimization
    * The bash script will choose the latest answer set and prompt you to copy it for visualization
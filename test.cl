(* models one-dimensional cellular automaton on a circle of finite radius
   arrays are faked as Strings,
   X's respresent live cells, dots represent dead cells,
   no error checking is done *)
class CellularAutomaton inherits IO {
    population_map : String;
   
    init(map : String) : SELF_TYPE {
        {
            population_map <- map;
            self;
        }
    };
   
    print() : SELF_TYPE {
        {
            out_string(population_map.concat("\n"));
            self;
        }
    };
   
    num_cells() : Int {
        population_map.length()
    };
   
    cell(position : Int) : String {
        population_map.substr(position, 1)
    };
   
    cell_left_neighbor(position : Int) : String {
        if position = 0 then
            cell(num_cells() - 1)
        else
            cell(position - 1)
        fi
    };
   
    cell_right_neighbor(position : Int) : String {
        if position = num_cells() - 1 then
            cell(0)
        else
            cell(position + 1)
        fi
    };
   
    (* a cell will live if exactly 1 of itself and it's immediate
       neighbors are alive *)
    cell_at_next_evolution(position : Int) : String {
        if (if cell(position) = "X" then 1 else 0 fi
            + if cell_left_neighbor(position) = "X" then 1 else 0 fi
            + if cell_right_neighbor(position) = "X" then 1 else 0 fi
            = 1)
        then
            "X"
        else
            "."
        fi
    };
   
    evolve() : SELF_TYPE {
        (let position : Int in
        (let num : Int <- num_cells[] in
        (let temp : String in
            {
                while position < num loop
                    {
                        temp <- temp.concat(cell_at_next_evolution(position));
                        position <- position + 1;
                    }
                pool;
                population_map <- temp;
                self;
            }
        ) ) )
    };
};

class Main {
    cells : CellularAutomaton;
   
    main() : SELF_TYPE {
        {
            cells <- (new CellularAutomaton).init("         X         ");
            cells.print();
            (let countdown : Int <- 20 in
                while countdown > 0 loop
                    {
                        cells.evolve();
                        cells.print();
                        countdown <- countdown - 1;
                    
                pool
            );  (* end let countdown *)
            self;
        }
    };
};


(* Writing more tests *)

*)

"\0\\1\2\3\\4\\\5\\n\b\t\f\0\9\h\l\s"

"Breaking line in a string \n line break"

!variavel = 4

_variavel = 5

" These are two quotes \"inside the string\""

3 > 5

greater_than = ">"

"End line inside \
the string"

"THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!   THIS IS THE BIGGEST STRING!!!"

object.property.get_property()

3three (* this is valid *)

invalid-identifier

gabriel&mariano

"I will comment inside (*this string *)"

class else fi if in inherits isvoid let loop then while case esac new of not

true false tRUe fALse

True False

clASS ELse FI iF IN inheRIts iSVoid Let lOOp tHEN wHIle CAse eSAc NEW OF nOT

"Goodbye this is the End of File...

# Load into GAP using Read("gaptypes.g"); and export using
# GAPTypesToJson("gap_types.json");

# Operations
# Families (not necessary, there is an unbounded number of
#           them and they do not convey any useful mathematical
#           information)
# Types of Installed Methods ( with filters )

LoadPackage("json");
LoadPackage("io");

FindOperationId := function( oper )
    local i;

    if IsOperation(oper) then
        for i in [1..Length(OPERATIONS)/2] do
            if OPERATIONS[2*i - 1] = oper then
                return 2*i - 1;
            fi;
        od;
        return fail;
    else
        Error("not an operation");
    fi;
    return fail;
end;

FiltersForOperation := function( oper )
    local res, res2, filts, opid, fset, flags;

    res := [];
    opid := FindOperationId(oper);

    filts := OPERATIONS[opid + 1];

    for fset in filts do
        res2 := [];
        for flags in fset do
            Add(res2, List(TRUES_FLAGS(flags), x -> FILTERS[x]));
        od;
        Add(res, res2);
    od;

    return res;
end;

GAPAndFilterUnpack := function(t)
    local res;

    res := [];

    if IsOperation(t) then
        if (IsInt(FLAG1_FILTER(t)) and IsInt(FLAG2_FILTER(t)))
        then
            Add(res, NAME_FUNC(t));
        else
            Append(res, GAPAndFilterUnpack(FLAG1_FILTER(t)));
            Append(res, GAPAndFilterUnpack(FLAG2_FILTER(t)));
        fi;
    fi;
    return res;
end;

GAPFilterToFilterType := function(fid)
    if INFO_FILTERS[fid] in FNUM_CATS then
        return "GAP_Category";
    elif INFO_FILTERS[fid] in FNUM_REPS then
        return "GAP_Representation";
    elif INFO_FILTERS[fid] in FNUM_ATTS then
        return "GAP_Attribute";
    elif INFO_FILTERS[fid] in FNUM_PROS then
        return "GAP_Property";
    elif INFO_FILTERS[fid] in FNUM_TPRS then
        return "GAP_TrueProperty";
    else
        return "GAP_Filter";
    fi;
end;

# Make GAP Type graph as a record
GAPTypesInfo := function()
    local res, lres, i, j, f, ff, a, meths, mpos;

    res := [ rec( name := "IsObject", type := "GAP_Category", implied := [] ) ];

    for i in [1..Length(FILTERS)] do
        if IsBound(FILTERS[i]) then
            lres := rec();
            f := FILTERS[i];

            lres.type := GAPFilterToFilterType(i);
            # if the filter is an attribute and FLAG1_FILTER of the filter
            # is not equal to it, then this is a tester.
            ff := TRUES_FLAGS(WITH_IMPS_FLAGS(FLAGS_FILTER(FILTERS[i])));
            ff := List(ff, function(f)
                          if IsBound(FILTERS[f]) then
                              return NAME_FUNC(FILTERS[f]);
                          else
                              return "<<unknown>>";
                          fi;
                      end);
            if lres.type = "GAP_Attribute" then
                if (FLAG1_FILTER(f)) <> 0 and (FLAG1_FILTER(f) <> i) then
                    lres.testerfor := NAME_FUNC(FILTERS[FLAG1_FILTER(f)]);
                fi;
                lres.filters := ff;
            elif lres.type = "GAP_Property" then
                lres.filters := ff;
            else
                lres.implied := ff;
            fi;
            lres.name := (NAME_FUNC(FILTERS[i]));
            Add(res, lres);
        fi;
    od;
    for i in [1..Length(ATTRIBUTES)] do
        lres := rec();
        lres.type := "GAP_Attribute";
        lres.filters := GAPAndFilterUnpack(ATTRIBUTES[i][2]);

        lres.name  := ATTRIBUTES[i][1];
        Add(res, lres);
    od;
    for i in [1..Length(OPERATIONS)/2] do
        lres := rec();
        lres.type := "GAP_Operation";
        lres.name := NAME_FUNC(OPERATIONS[2*i - 1]);
        lres.locations := OPERATIONS_LOCATIONS[2*i];
        lres.filters := FiltersForOperation(OPERATIONS[2*i - 1]);
        lres.filters := List(lres.filters, x->List(x,y -> List(y,NAME_FUNC)));

        lres.methods := rec( 0args := [], 1args := [], 2args := [],
                             3args := [], 4args := [], 5args := [],
                             6args := [] );

        for a in [1..6] do
            meths := METHODS_OPERATION(OPERATIONS[2*i - 1], a);
            
            for j in [1..Int(Length(meths)/(a + 4))] do
                mpos := (j - 1) * (a + 4) + 1;
                Add(lres.methods.(Concatenation(String(a),"args")),
                    rec(
                         filters := List([1..a],
                                         argnum ->
                                            List(TRUES_FLAGS(meths[mpos + argnum]), x -> NAME_FUNC(FILTERS[x]))
                                         ),
                         rank := meths[mpos + a + 2],
                         comment := meths[mpos + a + 3]
                        )
                   );
            od;
        od;

        Add(res, lres);
    od;
    return res;
end;


# Write the graph of type info to JSon file
GAPTypesToJson := function(file)
    local fd, n;

    fd := IO_File(file, "w");
    if fd = fail then
        Error("Opening file ", file, "failed.");
    fi;
    n := IO_Write(fd, GapToJsonString(GAPTypesInfo()));
    IO_Close(fd);

    return n;
end;


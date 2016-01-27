# Load into GAP using Read("gaptypes.g"); and export using
# GAPTypesToJson("gap_types.json");

LoadPackage("json");
LoadPackage("io");


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
        return "GAP_Tester";
    else
        return "GAP_Filter";
    fi;
end;

# Make GAP Type graph as a record
GAPTypesInfo := function()
    local  res, lres, i, ff;

    res := rec();

    for i in [1..Length(FILTERS)] do
        if IsBound(FILTERS[i]) then
            lres := rec();

            lres.type := GAPFilterToFilterType(i);

            ff := TRUES_FLAGS(WITH_IMPS_FLAGS(FLAGS_FILTER(FILTERS[i])));
            lres.implied := List(ff,
                               function(f)
                                   if IsBound(FILTERS[f]) then
                                       return NAME_FUNC(FILTERS[f]);
                                   else
                                       return "<<unknown>>";
                                   fi;
                               end);
            res.(NAME_FUNC(FILTERS[i])) := lres;
        fi;
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


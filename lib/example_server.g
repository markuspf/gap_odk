LoadPackage("scscp");

InstallSCSCPprocedure( "DihedralGroup", DihedralGroup, 1, 1);

InstallSCSCPprocedure( "DihedralGroupAsPermGroup", n -> DihedralGroup(IsPermGroup,n), 1, 1);

RunSCSCPserver( "localhost", 26133 );
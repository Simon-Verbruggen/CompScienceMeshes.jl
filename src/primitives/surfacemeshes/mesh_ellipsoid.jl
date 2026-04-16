using CompScienceMeshes
using GmshTools

"""
    gmshellipsoid(a, b, c, delta)

Create a mesh of a ellipsoid with axes `a`,`b` and `c` (x-, y- and z-directions respectively) by transforming a sphere.

The target edge size is `delta`.
"""

function gmshellipsoid(a, b, c, delta; tempname=tempname())

    fn = tempname
    io = open(fn, "w")
    close(io)
    fno = tempname * ".msh"

    gmsh.initialize()
    gmsh.option.setNumber("General.Terminal", 0)
    gmsh.option.setNumber("Mesh.MshFileVersion",2)
    gmsh.open(fn)
    gmsh.model.add("spheroid")


    # Create a unit sphere (returns the tag of the volume)
    vol = gmsh.model.occ.addSphere(0.0, 0.0, 0.0, 1.0)

    # Build the affine transform vector (row-major order)
    T = [
        a, 0, 0, 0,
        0, b, 0, 0,
        0, 0, c, 0,
        0, 0, 0, 1
    ]

    # Apply the transformation to the VOLUME (dimension = 3)
    gmsh.model.occ.affineTransform([(3, vol)], T)

    gmsh.model.occ.synchronize()

    pts = gmsh.model.getEntities(0)
    for (dim, tag) in pts
        gmsh.model.mesh.setSize([(dim, tag)], delta)
    end

    gmsh.model.mesh.generate(2)
    gmsh.write(fno)

    gmsh.finalize()

    m = CompScienceMeshes.read_gmsh_mesh(fno)

    rm(fno)
    rm(fn)

    return m

end
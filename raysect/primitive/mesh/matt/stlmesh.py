import numpy
from mesh import Mesh

#: Automatically detect whether the output is a TTY, if so, write ASCII
#: otherwise write BINARY
AUTOMATIC = 0
#: Force writing ASCII
ASCII = 1
#: Force writing BINARY
BINARY = 2

#: Amount of bytes to read while using buffered reading
BUFFER_SIZE = 4096
#: The amount of bytes in the header field
HEADER_SIZE = 80
#: The amount of bytes in the count field
COUNT_SIZE = 4
#: The maximum amount of triangles we can read from binary files
MAX_COUNT = 1e6


class StlMesh(Mesh):

    dtype = numpy.dtype([
        ('normals', numpy.float32, (3, )),
        ('vectors', numpy.float32, (3, 3)),
        ('attr', numpy.uint16, (1, )),
    ])

    def __init__(self, filename, mode=AUTOMATIC, calculate_normals=True):
        """Load a mesh from an STL file.

        Can automatically detects binary versus ascii STL files. Also the format can be specified.

        :param str filename: The file to load
        :param int mode: Automatically detect the filetype or force binary/ascii
        :param bool calculate_normals: Whether to update the normals
        """

        if mode == ASCII:
            solid_name, data = self._load_ascii(filename)
        else:
            raise NotImplementedError('Binary and Automatic .stl mode not implemented yet.')

        super().__init__(data, calculate_normals, name=solid_name)

    @classmethod
    def _load_ascii(cls, filename):
        fh = open(filename, 'r')

        # TODO - need to support the possibility of multiple 'solid' blocks defined in a .stl file.
        # Get the name from the first line
        line = cls._get_ascii_line(fh)
        if not line.startswith('solid'):
            raise ValueError('ASCII STL files should start with solid <space>. The application that produced this STL '
                             'file may be faulty, please report this error. The erroneous line: {}'.format(line))
        solid_name = line[5:].strip()

        meshdata = numpy.fromiter(cls._ascii_reader(fh), dtype=cls.dtype)

        return solid_name, meshdata

    @classmethod
    def _ascii_reader(cls, fh):

        while True:
            try:
                normal = cls._get_ascii_line(fh, 'facet normal')
                assert cls._get_ascii_line(fh) == 'outer loop'
                v0 = cls._get_ascii_line(fh, 'vertex')
                v1 = cls._get_ascii_line(fh, 'vertex')
                v2 = cls._get_ascii_line(fh, 'vertex')
                assert cls._get_ascii_line(fh) == 'endloop'
                assert cls._get_ascii_line(fh) == 'endfacet'
                attrs = 0
                yield (normal, (v0, v1, v2), attrs)
            except AssertionError as e:
                raise RuntimeError(e)
            except StopIteration:
                break

    @classmethod
    def _get_ascii_line(cls, fh, prefix=''):
        # get next line, remove whitespace i.e. indentation, newline character, etc
        line = fh.readline().lower().strip()

        if prefix:
            if line.startswith(prefix):
                values = line.replace(prefix, '', 1).strip().split()
            elif line.startswith('endsolid'):
                raise StopIteration()
            else:
                raise RuntimeError('{} should start with {}'.format(line, prefix))

            if len(values) == 3:
                return [float(v) for v in values]
            else:
                raise RuntimeError('Incorrect number of values in line: {}'.format(line))
        else:
            return line


if __name__ == "__main__":
    stlfile = "/home/matt/ccfe/stl/MAST-M9-BEAM_DUMPS_+_GDC_ascii.stl"
    mesh = StlMesh(stlfile, mode=ASCII)
    print('hello world')

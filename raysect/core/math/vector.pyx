# cython: language_level=3

#Copyright (c) 2014, Dr Alex Meakins, Raysect Project
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#     1. Redistributions of source code must retain the above copyright notice,
#        this list of conditions and the following disclaimer.
#
#     2. Redistributions in binary form must reproduce the above copyright
#        notice, this list of conditions and the following disclaimer in the
#        documentation and/or other materials provided with the distribution.
#
#     3. Neither the name of the Raysect Project nor the names of its
#        contributors may be used to endorse or promote products derived from
#        this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

import numbers
cimport cython
from libc.math cimport sqrt

cdef class Vector:
    """
    Represents a mathematical vector in 3D affine space.
    """
    
    def __init__(self, v = (1.0, 0.0, 0.0)):
        """
        Vector constructor.
        
        If no initial values are passed, Vector defaults to a unit vector
        aligned with the x-axis: [1.0, 0.0, 0.0]
        
        Any three (or more) item indexable object can be used to initialise the
        vector. The x, y and z coordinates will be assigned the values of 
        the items at indexes [0, 1, 2].
        
        e.g. Vector([4.0, 5.0, 6.0]) sets the x, y and z coordinates as 4.0,
        5.0 and 6.0 respectively.
        """
        
        try:
            
            self.d[0] = v[0]
            self.d[1] = v[1]
            self.d[2] = v[2]
            
        except:
            
            raise TypeError("Vector can only be initialised with an indexable object, containing numerical values, of length >= 3 items.")

    def __repr__(self):
        """Returns a string representation of the Vector object."""

        return "Vector([" + str(self.d[0]) + ", " + str(self.d[1]) + ", " + str(self.d[2]) + "])"

    property x:
        """The x coordinate."""
        
        def __get__(self):

            return self.d[0]

        def __set__(self, double v):

            self.d[0] = v

    property y:
        """The y coordinate."""

        def __get__(self):

            return self.d[1]

        def __set__(self, double v):

            self.d[1] = v

    property z:
        """The z coordinate."""
    
        def __get__(self):

            return self.d[2]

        def __set__(self, double v):

            self.d[2] = v

    property length:
        """
        The vector's length.
        
        Raises a ZeroDivisionError if an attempt is made to change the length of
        a zero length vector. The direction of a zero length vector is
        undefined hence it can not be lengthened.
        """
        
        def __get__(self):
            
            return self.get_length()
        
        def __set__(self, double v):
            
            self.set_length(v)
            
    def __getitem__(self, int i):
        """Returns the vector coordinates by index ([0,1,2] -> [x,y,z])."""

        if i < 0 or i > 2:
            raise IndexError("Index out of range [0, 2].")
            
        return self.d[i]

    def __neg__(self):
        """Reverses the vector's direction."""
                
        cdef Vector v
        
        v = Vector.__new__(Vector)
        v.d[0] = -self.d[0]
        v.d[1] = -self.d[1]
        v.d[2] = -self.d[2]
    
        return v

    def __add__(object x, object y):
        """Vector addition."""
        
        # TODO: add normal + vector and vector + normal
        
        cdef Vector vx, vy, vr
        #cdef Point p
        
        if isinstance(x, Vector) and isinstance(y, Vector):
            
            vx = <Vector>x
            vy = <Vector>y
            
            # TODO: make new_vector(x,y,z) inline utility function and replace this
            vr = Vector.__new__(Vector)
            vr.d[0] = vx.d[0] + vy.d[0]
            vr.d[1] = vx.d[1] + vy.d[1]
            vr.d[2] = vx.d[2] + vy.d[2]
        
            return vr
            
        #else isinstance(x, Point):
            
            #p = <Point>x
        
            #TODO: handle point + vector
        
        else:

            raise TypeError("Unsupported operand type. Expects a Vector, Normal or Point.")
              
    def __sub__(object x, object y):
        """Vector subtraction."""
        
        # TODO: add normal - vector and vector - normal
        
        cdef Vector vx, vy, vr
        #cdef Point p
        
        if isinstance(x, Vector) and isinstance(y, Vector):
            
            vx = <Vector>x
            vy = <Vector>y
            
            # TODO: make new_vector(x,y,z) inline utility function and replace this
            vr = Vector.__new__(Vector)
            vr.d[0] = vx.d[0] - vy.d[0]
            vr.d[1] = vx.d[1] - vy.d[1]
            vr.d[2] = vx.d[2] - vy.d[2]
        
            return vr
            
        #else isinstance(x, Point):
            
            #p = <Point>x
        
            #TODO: handle point + vector
        
        else:

            raise TypeError("Unsupported operand type. Expects a Vector, Normal or Point.")
            
    def __mul__(object x, object y):
        """Multiply vector by a scalar."""

        cdef double m
        cdef Vector v, r
        
        if isinstance(x, numbers.Real) and isinstance(y, Vector):
        
            m = <double>x
            v = <Vector>y
        
        elif isinstance(x, Vector) and isinstance(y, numbers.Real):
        
            m = <double>y
            v = <Vector>x
        
        else:
        
            raise TypeError("Unsupported operand type. Expects a real number.")
        
        r = Vector.__new__(Vector)
        r.d[0] = m * v.d[0]
        r.d[1] = m * v.d[1]
        r.d[2] = m * v.d[2]
        
        return r

    def __truediv__(object x, object y):
        """Division of a vector by a scalar."""

        cdef double d
        cdef Vector v, r
        
        if isinstance(x, Vector) and isinstance(y, numbers.Real):
        
            d = <double>y

            # prevent divide my zero
            if d == 0.0:
                raise ZeroDivisionError("Cannot divide a vector by a zero scalar.")

            v = <Vector>x
            
            with cython.cdivision(True):
                d = 1.0 / d 
            
            r = Vector.__new__(Vector)
            r.d[0] = d * v.d[0]
            r.d[1] = d * v.d[1]
            r.d[2] = d * v.d[2]            
            
            return r
        
        else:
        
            raise TypeError("Unsupported operand type. Expects a real number.")

    def dot(self, Vector v):
        """
        Calculates the dot product between this vector and the supplied vector.
        
        Returns a scalar.
        """
        
        # TODO: replace with cdef utility function
        return self.d[0] * v.d[0] + self.d[1] * v.d[1] + self.d[2] * v.d[2]
    
    def cross(self, Vector v):
        """
        Calculates the cross product between this vector and the supplied
        vector: 
        
            C = A.cross(B) <=> C = A x B
            
        Returns a Vector.
        """

        # TODO: replace with cdef utility function
        cdef Vector r
        r = Vector.__new__(Vector)
        r.d[0] = self.d[1] * v.d[2] - v.d[1] * self.d[2]
        r.d[1] = self.d[2] * v.d[0] - v.d[2] * self.d[0]
        r.d[2] = self.d[0] * v.d[1] - v.d[0] * self.d[1]
    
        return r
 
    def normalise(self):
        """
        Returns a normalised copy of the vector.
        
        The returned vector is normalised to length 1.0 - a unit vector.
        """

        # TODO: replace with cdef utility function
    
        cdef double t
        cdef Vector r
    
        # if current length is zero, problem is ill defined
        t = self.d[0] * self.d[0] + self.d[1] * self.d[1] + self.d[2] * self.d[2]
        if t == 0.0:
            
            raise ZeroDivisionError("A zero length vector can not be normalised as the direction of a zero length vector is undefined.")
        
        # normalise and rescale vector
        with cython.cdivision(True):
            
            t = 1.0 / sqrt(t)

        r = Vector.__new__(Vector)
        r.d[0] = self.d[0] * t
        r.d[1] = self.d[1] * t
        r.d[2] = self.d[2] * t
    
        return r
  
    # cython api ---------------------------------------------------------------

    # x coordinate getters/setters
    cdef inline double get_x(self):
        
        return self.d[0]
    
    cdef inline void set_x(self, double v):
        
        self.d[0] = v

    # y coordinate getters/setters
    cdef inline double get_y(self):
        
        return self.d[1]
    
    cdef inline void set_y(self, double v):
        
        self.d[1] = v        
        
    # z coordinate getters/setters
    cdef inline double get_z(self):
        
        return self.d[2]
    
    cdef inline void set_z(self, double v):
        
        self.d[2] = v
        
    # length getters/setters    
    cdef inline double get_length(self):
        
        return sqrt(self.d[0] * self.d[0] + self.d[1] * self.d[1] + self.d[2] * self.d[2])
        
    cdef inline void set_length(self, double v) except *:
        
        cdef double t
            
        # if current length is zero, problem is ill defined
        t = self.d[0] * self.d[0] + self.d[1] * self.d[1] + self.d[2] * self.d[2]
        if t == 0.0:
            
            raise ZeroDivisionError("A zero length vector can not be rescaled as the direction of a zero length vector is undefined.")
        
        # normalise and rescale vector
        with cython.cdivision(True):
            
            t = v / sqrt(t)

        self.d[0] = self.d[0] * t
        self.d[1] = self.d[1] * t
        self.d[2] = self.d[2] * t

   
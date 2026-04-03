import slangpy as spy
import struct

class hittable:
    def __init__(self, mat: int = 0):
        self.mat = mat

    def pack(self):
        pass

class sphere(hittable):
    def __init__(self, 
                 center = spy.float3(0.0, 0.0, 0.0),
                 radius: float = 1.0,
                 mat: int = 0):
        super().__init__(mat)
        self.center = center
        self.radius = radius

    def pack(self):
        return struct.pack("ffffI",
                            self.center[0], self.center[1], self.center[2],
                            self.radius,
                            self.mat)
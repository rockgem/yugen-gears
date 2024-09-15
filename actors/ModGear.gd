extends Node
class_name ModGear

var N
var P
var D
var A
var PA
var parentID
var rot
var gearangle
var ratio
var totalratio
var jointangle
var baseangle
var rsc
var offsetx
var offsety
var x
var y
var svg
var w
var dim
var axlejoint

func _init(N, P, A, parentID, gearangle, baseangle, rsc, svg, w, dim, PA=27) -> void:
	self.N = N
	self.P = P
	self.D = self.N / self.P
	self.A = A
	self.PA = PA
	self.parentID = parentID
	self.rot = 0
	self.gearangle = gearangle
	self.ratio = 1
	self.totalratio = 1
	self.jointangle = A
	self.baseangle = baseangle
	self.rsc = rsc
	self.offsetx = 0
	self.offsety = 0
	self.x = 0
	self.y = 0
	self.svg = svg
	self.w = w
	self.dim = dim
	self.axlejoint = false

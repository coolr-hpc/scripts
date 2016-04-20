#!/bin/bash

for app in bt.C.x cg.C.x dc.B.x ep.D.x ft.B.x is.C.x lu.C.x mg.B.x sp.C.x ua.C.x
do
	./run-app.sh $1 $app
done

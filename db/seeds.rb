# encoding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Indices reales segun http://www.cifrasonline.com.ar/cifras/index.php/content/view/full/76/%28offset%29/cac
Indice.create([{periodo: '1/1/2011', valor: 817.20, denominacion: 'Costo de construcción'},
    {periodo: '1/1/2011', valor: 751.60, denominacion: 'Materiales'},
    {periodo: '1/1/2011', valor: 891.10, denominacion: 'Mano de obra'}])

require 'csv'
require 'prawn'

path = "C:\\Users\\E6430\\Documents\\ruby programs\\personalizer\\a.csv"

class Code
	@@code_quant = 0
	attr_accessor:code, :num
	def initialize(code)
		@@code_quant += 1
		@code = code #code value
		@num = @@code_quant #code number
	end
end
class Batch
	@@batch_quant = 0
	
	attr_accessor:collection, :num, :position
	def initialize(x=0,y=0)
		@@batch_quant += 1 
		@collection = [] #collection of Codes objects
		@num = @@batch_quant #gets id
		@position = {xaxis:x, yaxis:y}
	end
	
	def add_code(code)
		@collection << code
	end
	
	def set_position(x=0,y=0)
		@position = {xaxis:x, yaxis:y}
	end
	
	def to_s
		"Batch number: #{@num}. Contains codes from #{@collection[0].num} to #{@collection[-1].num}."
	end
end

class Bundle
	attr_accessor:batches
	def initialize
		@batches = [] #the collection of batches
	end
	
	def create_bundle(base,per_batch) #per_batch determines how many codes are in single batch.
		while base.all_codes != [] #it will shift (pop first element) codes from our list. If there's no more codes left, loop will stop.
			tmp_batch = Batch.new
			per_batch.times do |jmp| # this loop is adding codes to the batches
				if base.all_codes == [] #it checks if there are still some codes left, we don't want nils in our batch
					break
				end
				tmp_batch.add_code(base.all_codes.shift) 
			end
			@batches << tmp_batch #adds batch to the collection of batches
		end
	end
end

class Base
	attr_accessor:all_codes
	def initialize(file) #file is the path to the .csv, 
		@all_codes = [] #array of all codes, elements will be popped out when filling batches
		CSV.foreach(file) do |row| #this one will take all values from csv and put into temporary array
			@all_codes << Code.new(row[0]) #row from csv is a table, but we need a value of it that's why we use "row[0]"
		end	
	end	
end

class Genfile
	def initialize
		@pdf = Prawn::Document.new
	end
	
	def on_pg_positioning(per_page,bund_obj)
		per_page.times do |sb|
			bund_obj.batches[sb].set_position(0,10*sb)
		end
	end
	
	def make_section(per_page, bund_obj)
		section = []
		per_page.times {section << bund_obj.batches.shift}
		return section			
	end
	
	def single_codes_page(per_page, bund_obj)
		section_batches = make_section(per_page,bund_obj)
		section_batches.each do |single_batch|
			@pdf.draw_text "#{single_batch.collection.shift.code}", at:[single_batch.position[:xaxis],single_batch.position[:yaxis]]
		end
		@pdf.render_file "tescior.pdf"
	end
	
end
db = Base.new(path)
x = Bundle.new
x.create_bundle(db,10)
puts x.batches[0]#.collection[0].code

f = Genfile.new
f.on_pg_positioning(5,x)
f.single_codes_page(5,x)
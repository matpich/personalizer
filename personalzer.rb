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
	attr_accessor:batches, :size
	def initialize
		@batches = [] #the collection of batches
		@size = @batches.size
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
		@size = @batches.size
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
	
	def set_positions(per_page, bund_obj)
		positions = [[0,0],[0,20],[0,40],[0,60],[0,80]]# I will add methods to customize it in future
		sections = (bund_obj.size/per_page).to_i
		
		sections.times do |sec|
			per_page.times do |batch|
				puts bund_obj.batches[batch+(per_page*sec)].set_position(positions[batch][0],positions[batch][1])
			end
		end
	end
	
	def single_codes_page(per_page, bund_obj)
		per_page.times do |single_batch|
			@pdf.draw_text "#{bund_obj.batches[single_batch].collection.shift.code}", at:[bund_obj.batches[single_batch].position[:xaxis],bund_obj.batches[single_batch].position[:yaxis]]
		end
		@pdf.start_new_page
	end
	
	def make_doc
		@pdf.render_file "testowiutki.pdf"
	end
end
db = Base.new(path)
bund_obj = Bundle.new
bund_obj.create_bundle(db,10)
#puts bund_obj.size
#puts bund_obj.batches[0]#.collection[0].code

f = Genfile.new
f.set_positions(5,bund_obj)
10.times {f.single_codes_page(5,bund_obj)}
f.make_doc
class TimepassController < ApplicationController
  @@number = 1

  class << self
    def number
      @@number
    end
  end

  def increment
    @@number = 20
  end

  def index
    
  end

  def button_click
    @@number += 1
    respond_to do |format|
      format.json{
        render json: {
          "name": "Mohan",
          "age": 24,
          "number": @@number
        }.to_json
      }
    end
  end
    
end

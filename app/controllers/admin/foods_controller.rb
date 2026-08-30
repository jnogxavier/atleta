module Admin
  class FoodsController < ApplicationController
    include AdminAuthorization
    before_action :set_food, only: [ :edit, :update, :destroy ]

    def index
      @foods = Food.order(:name).page(params[:page]).per(10)
    end

    def new
      @food = Food.new
      respond_to do |format|
        format.html
        format.json { render json: { html: render_to_string(partial: "form", locals: { food: @food }) } }
      end
    end

    def create
      @food = Food.new(food_params)

      if @food.save
        respond_to do |format|
          format.json { render json: @food, status: :created }
          format.html { redirect_to admin_foods_path, notice: "Alimento criado com sucesso!" }
        end
      else
        respond_to do |format|
          format.json { render json: @food.errors, status: :unprocessable_entity }
          format.html { render :new, status: :unprocessable_entity }
        end
      end
    end

    def edit
      respond_to do |format|
        format.html
        format.json { render json: { html: render_to_string(partial: "form", locals: { food: @food }) } }
      end
    end

    def update
      if @food.update(food_params)
        respond_to do |format|
          format.json { render json: @food }
          format.html { redirect_to admin_foods_path, notice: "Alimento atualizado com sucesso!" }
        end
      else
        respond_to do |format|
          format.json { render json: @food.errors, status: :unprocessable_entity }
          format.html { render :edit, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @food.destroy

      respond_to do |format|
        format.json { render json: { success: true } }
        format.html { redirect_to admin_foods_path, notice: "Alimento removido com sucesso!" }
      end
    end

    def categories
      render json: Food.categories
    end

    def search
      query = params[:q].to_s.strip

      if query.present?
        # Remove commas and normalize spaces so "coco verde" matches "Coco,  verde, cru",
        # then escape SQL LIKE wildcards (%, _) to prevent wildcard injection.
        query_normalized = query.gsub(",", "").gsub(/\s+/, " ").strip
        query_sanitized = ActiveRecord::Base.sanitize_sql_like(query_normalized)
        foods = Food.where("REGEXP_REPLACE(REPLACE(unaccent(LOWER(name)), ',', ''), '\\s+', ' ', 'g') ILIKE unaccent(?)", "%#{query_sanitized}%").order(:name).limit(30)
      else
        foods = Food.order(:name).limit(30)
      end

      render json: FoodSerializer.render_collection(foods, view: :detailed)
    end

    private

    def set_food
      @food = Food.find(params[:id])
    end

    def food_params
      params.require(:food).permit(:name, :category, :energy_kcal, :protein_g, :carbohydrate_g, :fat_g)
    end
  end
end

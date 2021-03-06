class ProductsController < ApplicationController
  @number_pages = 10
  # GET /products or /products.json
  def index
    @products = Product.all_products
    add_new_price
    render json: @products, status: :ok
  end

  # GET /get_products/:products_ids
  def getting_products
    array = params["products_ids"].split(",")
    @products = Product.show_product(array)
    add_new_price
    render json: @products, status: :ok
  end

  # GET /products/:sort_by/:order || GET /products/:product_id/:sort_by/:order
  def sort
    by_sort = params["by_sort"]
    order = params["order"].eql?("A-Z") || params["order"].eql?("asc") ? "ASC" : "DESC"
    category_id = params["category_id"]

    @products = if category_id.nil?
                  Product.sort_everything(by_sort, order)
                else
                  Product.sort_by_category(category_id, by_sort, order)
                end

    if @products.empty?
      render json: { error: "Category ID wrong or doesn't has products" }, status: :bad_request
    else
      add_new_price
      render json: @products, status: :ok
    end
  end

  # GET /clasificacion_types
  def clasification_types
    types = ["name A-Z", "name Z-A", "price asc", "price desc", "discount asc", "discount desc"]
    render json: types
  end

  # GET /search/:name_product(/:by_sort/:order)
  def search
    product_name = params["search"]
    by_sort = params["by_sort"]
    order = params["order"].eql?("A-Z") || params["order"].eql?("asc") ? "ASC" : "DESC"
    @products = Product.search(product_name) if by_sort.nil?
    @products = Product.search_with_sort(product_name, by_sort, order) unless by_sort.nil?
    add_new_price

    render json: @products, status: :ok
  end

  private

  def product_params
    # params.require(:product).permit "category_id"
    params.require(:category_id)
  end

  # Este método añade al array de hashes, que devuelve la consulta, el precio aplicado su descuento, y la cantidad que se descontó
  # Añadí este método para evitar tener que hacer los calculos en el frontent, y simplemente llamarlos.
  def add_new_price
    @products.map! do |product|
      product.update({ "new_price" => product["price"] * (100 - product["discount"]) / 100 })
      product.update({ "saving" => product["price"] - product["new_price"] })
    end
    @products = @products.each_slice(10).to_a
  end
end

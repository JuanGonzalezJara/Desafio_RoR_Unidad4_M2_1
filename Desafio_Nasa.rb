require 'uri'
require 'net/http'
require 'json'

#metodo que recibe una api url y retorna la respuesta
def request(url_requested)
    url = URI(url_requested)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true # Se agrega esta línea para definir el uso de SSL
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER # Se agrega para eliminar vulnerabilidad Man in the Middle
    request = Net::HTTP::Get.new(url)
    request["cache-control"] = 'no-cache'
    request["postman-token"] = '5f4b1b36-5bcd-4c49-f578-75a752af8fd5'
    response = http.request(request)
    #Se agrega symbolize_names para que las claves del hash sean simbolos y no strings
    return JSON.parse(response.body, symbolize_names: true)
end

#metodo que recibe un hash de api response y retorna un string con un html web construida
def buid_web_page(datos_hash)
    html = "<html>\n<head>\n</head>\n<body>\n<ul>\n" 
    datos_hash.each do |u|
        html +=("<li><img src='#{u[:img_src]}' width='300'></li>\n")
    end
    html += "</ul>\n</body>\n</html>"
    return html
end

#metodo que recibe un hash de api response y retorna un hash con datos sobre la respuesta (nombre camara y cantidad fotos)
def photos_count(camera)
    cantidad_fotos = Hash.new(0)
    camera.each  do |c|
        nombre_camara = c[:camera][:name]
        cantidad_fotos[nombre_camara] += 1
    end

    puts cantidad_fotos
end

#hacemos la peticion a la api y guardamos el resultado en la variable data
data = request('https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?sol=1&api_key=1LR6thsMgEo4kdEP6aBOv3u6jXW8YIO0GCem9H3D')[:photos][0..9]

#metodo para escribir un archivo indicando nombre + extension y contenido
File.write('index.html',buid_web_page(data))

#hacemos la peticion a la api y guardamos el resultado en la variable data
data_total = request('https://api.nasa.gov/mars-photos/api/v1/rovers/curiosity/photos?sol=1&api_key=1LR6thsMgEo4kdEP6aBOv3u6jXW8YIO0GCem9H3D')[:photos]
#llamamos al metodo que cuenta la cantidad de fotos por camara y lo devuelve en un hash
photos_count(data_total)
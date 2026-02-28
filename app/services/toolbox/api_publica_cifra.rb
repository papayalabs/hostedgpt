class Toolbox::APIPublicaCifra < Toolbox
  # Toolbox para acceder a la API Pública de Cifra.
  # Documentación: ver ACCESO_API_PUBLICA.md
  #
  # Flujo de autenticación:
  #   1. POST /api_publica/login con header `api-key` → obtiene token
  #   2. signature = HMAC_SHA256(secret_key, token) en hexadecimal
  #   3. Peticiones autenticadas con headers Authorization + signature
  #
  # Credenciales configuradas en Setting:
  #   - api_publica_cifra_url       → URL base (por defecto http://localhost:3000)
  #   - api_publica_cifra_api_key   → clave pública del cliente API
  #   - api_publica_cifra_secret_key → clave privada para el HMAC

  class << self
    # Caché del token a nivel de clase para reutilizarlo entre llamadas
    # dentro de la misma hora (el token caduca en 1 hora)
    attr_accessor :token_cache
  end

  # ---------------------------------------------------------------------------
  # Gestión económica - Cobros
  # ---------------------------------------------------------------------------

  describe :obtener_empresas, <<~S
    Obtiene el listado de empresas del centro educativo asociadas a la gestión económica.
    Devuelve un máximo de 1000 registros por petición.
  S

  def obtener_empresas
    empresas = get(url("/api_publica/v1/gestion_economica/empresas"),token_vigente).param({})
    {
      total: empresas.size,
      empresas: empresas,
      message_to_user: "Se obtuvieron #{empresas.size} empresas"
    }
  end

  describe :obtener_cobros, <<~S
    Obtiene el listado de cobros/recibos de gestión económica del centro.
    Devuelve un máximo de 1000 registros por petición.
    Filtros opcionales:
      - estado: 'cobrado' o 'pendiente'
      - forma_pago_id: identificador numérico de la forma de pago (obtener con obtener_formas_pago)
      - fecha_from: fecha inicio de recibo en formato YYYY-MM-DD
      - fecha_to: fecha fin de recibo en formato YYYY-MM-DD
  S

  def obtener_cobros(estado_s: nil, forma_pago_id_i: nil, fecha_from_s: nil, fecha_to_s: nil)
    params = {
      estado: estado_s,
      forma_pago_id: forma_pago_id_i,
      fecha_recibo_from: fecha_from_s,
      fecha_recibo_to: fecha_to_s
    }.compact
    cobros = get(url("/api_publica/v1/gestion_economica/cobros"),token_vigente).param(params)
    {
      total: cobros.size,
      cobros: cobros,
      message_to_user: "Se obtuvieron #{cobros.size} cobros"
    }
  end

  describe :obtener_formas_pago, <<~S
    Obtiene el listado de formas de pago disponibles en el centro
    (tarjeta, transferencia, domiciliación, efectivo, etc.).
    Útil para conocer los ids disponibles antes de filtrar cobros por forma_pago_id.
  S

  def obtener_formas_pago
    formas_pago = get(url("/api_publica/v1/gestion_economica/formas_pago"),token_vigente).param({})
    {
      total: formas_pago.size,
      formas_pago: formas_pago,
      message_to_user: "Se obtuvieron #{formas_pago.size} formas de pago"
    }
  end

  describe :obtener_modalidades, <<~S
    Obtiene el listado de modalidades/conceptos de gestión económica del centro,
    con información de importe, IVA, periodicidad y servicio asociado.
  S

  def obtener_modalidades
    modalidades = get(url("/api_publica/v1/gestion_economica/modalidades"),token_vigente).param({})
    {
      total: modalidades.size,
      modalidades: modalidades,
      message_to_user: "Se obtuvieron #{modalidades.size} modalidades"
    }
  end

  # ---------------------------------------------------------------------------
  # Usuarios
  # ---------------------------------------------------------------------------

  describe :obtener_usuarios, <<~S
    Obtiene el listado de usuarios del centro educativo.
    Filtros opcionales:
      - q: búsqueda libre por nombre u otros campos
  S

  def obtener_usuarios(q_s: nil)
    params = { q: q_s }.compact
    usuarios = get(url("/api_publica/v1/usuarios"),token_vigente).param(params)
    {
      total: usuarios.size,
      usuarios: usuarios,
      message_to_user: "Se obtuvieron #{usuarios.size} usuarios"
    }
  end

  describe :obtener_roles, <<~S
    Obtiene el listado de roles/perfiles disponibles en el centro
    (alumno, profesor, tutor, etc.).
  S

  def obtener_roles
    roles = get(url("/api_publica/v1/roles"),token_vigente).param({})
    {
      total: roles.size,
      roles: roles,
      message_to_user: "Se obtuvieron #{roles.size} roles"
    }
  end

  # ---------------------------------------------------------------------------
  # Estructura escolar
  # ---------------------------------------------------------------------------

  describe :obtener_annos_lectivos, <<~S
    Obtiene el listado de años lectivos del centro educativo.
  S

  def obtener_annos_lectivos
    annos = get(url("/api_publica/v1/annos_lectivos"),token_vigente).param({})
    {
      total: annos.size,
      annos_lectivos: annos,
      message_to_user: "Se obtuvieron #{annos.size} años lectivos"
    }
  end

  describe :obtener_estructuras, <<~S
    Obtiene la estructura escolar del centro: enseñanzas, cursos y grupos.
    Filtros opcionales:
      - anno_lectivo_id: limita la estructura a un año lectivo concreto
  S

  def obtener_estructuras(anno_lectivo_id_i: nil)
    params = { anno_lectivo_id: anno_lectivo_id_i }.compact
    estructuras = get(url("/api_publica/v1/estructuras"),token_vigente).param(params)
    estructuras = Array(estructuras)
    {
      total: estructuras.size,
      estructuras: estructuras,
      message_to_user: "Se obtuvieron #{estructuras.size} estructuras escolares"
    }
  end

  # ---------------------------------------------------------------------------
  # Convivencia
  # ---------------------------------------------------------------------------

  describe :obtener_incidencias, <<~S
    Obtiene el listado de incidencias de convivencia del centro educativo.
  S

  def obtener_incidencias
    incidencias = get(url("/api_publica/v1/incidencias"),token_vigente).param({})
    {
      total: incidencias.size,
      incidencias: incidencias,
      message_to_user: "Se obtuvieron #{incidencias.size} incidencias"
    }
  end

  # ---------------------------------------------------------------------------
  # Transporte
  # ---------------------------------------------------------------------------

  describe :obtener_rutas_transporte, <<~S
    Obtiene el listado de rutas de transporte escolar activas del centro.
  S

  def obtener_rutas_transporte
    rutas = get(url("/api_publica/v1/transporte/rutas"),token_vigente).param({})
    {
      total: rutas.size,
      rutas: rutas,
      message_to_user: "Se obtuvieron #{rutas.size} rutas de transporte"
    }
  end

  describe :obtener_paradas_transporte, <<~S
    Obtiene el listado de paradas de transporte escolar.
    Filtros opcionales:
      - turno_id: filtra las paradas de un turno concreto (se puede pasar como número entero)
  S

  def obtener_paradas_transporte(turno_id_i: nil)
    params = { turno_id: turno_id_i }.compact
    paradas = get(url("/api_publica/v1/transporte/paradas"),token_vigente).param(params)
    {
      total: paradas.size,
      paradas: paradas,
      message_to_user: "Se obtuvieron #{paradas.size} paradas de transporte"
    }
  end

  # ---------------------------------------------------------------------------
  # Servicios
  # ---------------------------------------------------------------------------

  describe :obtener_servicios, <<~S
    Obtiene el listado de servicios activos del centro educativo
    (comedor, actividades extraescolares, etc.).
  S

  def obtener_servicios
    servicios = get(url("/api_publica/v1/servicios/servicios"),token_vigente).param({})
    {
      total: servicios.size,
      servicios: servicios,
      message_to_user: "Se obtuvieron #{servicios.size} servicios"
    }
  end

  # ---------------------------------------------------------------------------
  # Autenticación
  # ---------------------------------------------------------------------------

  describe :hacer_login, <<~S
    Inicia sesión en la API pública de Cifra y obtiene un token de autenticación.
    Llama a este método antes de hacer cualquier otra petición, o si recibes un error de autenticación.
    El token se cachea automáticamente y se renueva cuando caduca.
  S

  def hacer_login
    token = ejecutar_login_uuid
    self.class.token_cache = { token: token, obtenido_en: Time.current }
    { token: token, message_to_user: "Login realizado correctamente" }
  end

  private

  def url(path)
    "#{base_url}#{path}"
  end

  def base_url
    Setting.api_publica_cifra_url.presence || "http://localhost:3000"
  end

  def api_key
    Setting.api_publica_cifra_api_key
  end

  def secret_key
    Setting.api_publica_cifra_secret_key.presence || "secret"
  end

  def cabeceras_auth
    t = token_vigente
    firma = calcular_firma(t)
    { Authorization: "Token token=#{t}", signature: firma }
  end

  def token_vigente
    cache = self.class.token_cache
    return cache[:token] if cache && cache[:obtenido_en] > 50.minutes.ago

    nuevo_token = ejecutar_login_uuid
    raise "Login fallido: no se obtuvo token" if nuevo_token.blank?

    self.class.token_cache = { token: nuevo_token, obtenido_en: Time.current }
    nuevo_token
  end

  def ejecutar_login
    respuesta = post(url("/api_publica/login")).header(:'api-key' => api_key).param({})
    respuesta.token
  end

  # Método alternativo para login usando uuid y body específico
  def ejecutar_login_uuid
    endpoint = url("/api/login?&uuid=111")
    body = {
      user: Setting.api_publica_cifra_user,
      password: Setting.api_publica_cifra_password
    }
    respuesta = post(endpoint).www_content.param(body)
    respuesta.try(:data)&.try(:token) || respuesta.try(:token)
  end

  def calcular_firma(token_s)
    OpenSSL::HMAC.hexdigest("sha256", secret_key, token_s)
  end
end

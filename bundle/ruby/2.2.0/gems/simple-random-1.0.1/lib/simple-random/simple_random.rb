class SimpleRandom
  def initialize
    @m_w = 521288629
    @m_z = 362436069
  end

  def set_seed(*args)
    if args.size > 1
      @m_w = args.first.to_i if args.first.to_i != 0
      @m_z = args.last.to_i if args.last.to_i != 0
    elsif args.first.is_a?(Numeric)
      @m_z = args.first.to_i if args.first.to_i != 0
    elsif args.first.is_a?(Time)
      x = (args.first.to_f * 1000000).to_i
      @m_w = x >> 16
      @m_z = x % 4294967296 # 2 ** 32
    else
      x = (Time.now.to_f * 1000000).to_i
      @m_w = x >> 16
      @m_z = x % 4294967296 # 2 ** 32
    end

    @m_w %= 4294967296
    @m_z %= 4294967296
  end

  # Produce a uniform random sample from the open interval (lower, upper).
  # The method will not return either end point.
  def uniform(lower = 0, upper = 1)
    raise 'Invalid range' if upper <= lower
    ((get_unsigned_int + 1) * (upper - lower) / 4294967296.0) + lower
  end

  # Sample normal distribution with given mean and standard deviation
  def normal(mean = 0.0, standard_deviation = 1.0)
    raise 'Invalid standard deviation' if standard_deviation <= 0
    mean + standard_deviation * ((-2.0 * Math.log(uniform)) ** 0.5) * Math.sin(2.0 * Math::PI * uniform)
  end

  # Get exponential random sample with specified mean
  def exponential(mean = 1)
    raise 'Mean must be positive' if mean <= 0
    -1.0 * mean * Math.log(uniform)
  end

  # Get triangular random sample with specified lower limit, mode, upper limit
  def triangular(lower, mode, upper)
    raise 'Upper limit must be larger than lower limit' if upper < lower
    raise 'Mode must lie between the upper and lower limits' if (mode < lower || mode > upper)
    f_c = (mode - lower) / (upper - lower)
    uniform_rand_num = uniform
    if uniform_rand_num < f_c
      lower + Math.sqrt(uniform_rand_num * (upper - lower) * (mode - lower))
    else
      upper - Math.sqrt((1 - uniform_rand_num) * (upper - lower) * (upper - mode))
    end
  end

  # Implementation based on "A Simple Method for Generating Gamma Variables"
  # by George Marsaglia and Wai Wan Tsang.  ACM Transactions on Mathematical Software
  # Vol 26, No 3, September 2000, pages 363-372.
  def gamma(shape, scale)
    if shape >= 1.0
      d = shape - 1.0 / 3.0
      c = 1 / ((9 * d) ** 0.5)
      while true
        v = 0.0
        while v <= 0.0
          x = normal
          v = 1.0 + c * x
        end
        v = v ** 3
        u = uniform
        if u < (1.0 - 0.0331 * (x ** 4)) || Math.log(u) < (0.5 * (x ** 2) + d * (1.0 - v + Math.log(v)))
          return scale * d * v
        end
      end
    elsif shape <= 0.0
      raise 'Shape must be positive'
    else
      g = gamma(shape + 1.0, 1.0)
      w = uniform
      return scale * g * (w ** (1.0 / shape))
    end
  end

  def chi_square(degrees_of_freedom)
    gamma(0.5 * degrees_of_freedom, 2.0)
  end

  def inverse_gamma(shape, scale)
    1.0 / gamma(shape, 1.0 / scale)
  end

  def beta(a, b)
    raise "Alpha and beta parameters must be positive. Received a = #{a} and b = #{b}." unless a > 0 && b > 0
    u = gamma(a, 1)
    v = gamma(b, 1)
    u / (u + v)
  end

  def weibull(shape, scale)
    raise 'Shape and scale must be positive' if shape <= 0.0 || scale <= 0.0

    scale * ((-Math.log(uniform)) ** (1.0 / shape))
  end

  def cauchy(median, scale)
    raise 'Scale must be positive' if scale <= 0

    median + scale * Math.tan(Math::PI * (uniform - 0.5))
  end

  def student_t(degrees_of_freedom)
    raise 'Degrees of freedom must be positive' if degrees_of_freedom <= 0

    normal / ((chi_square(degrees_of_freedom) / degrees_of_freedom) ** 0.5)
  end

  def laplace(mean, scale)
    u = uniform
    mean + Math.log(2) + ((u < 0.5 ? 1 : -1) * scale * Math.log(u < 0.5 ? u : 1 - u))
  end

  def log_normal(mu, sigma)
    Math.exp(normal(mu, sigma))
  end

  def dirichlet(*parameters)
    sample = parameters.map { |a| gamma(a, 1) }
    sum = sample.inject(0.0) { |sum, g| sum + g }
    sample.map { |g| g / sum }
  end

  private

  # This is the heart of the generator.
  # It uses George Marsaglia's MWC algorithm to produce an unsigned integer.
  # See http://www.bobwheeler.com/statistics/Password/MarsagliaPost.txt
  def get_unsigned_int
    @m_z = 36969 * (@m_z & 65535) + (@m_z >> 16);
    @m_w = 18000 * (@m_w & 65535) + (@m_w >> 16);
    ((@m_z << 16) + (@m_w & 65535)) % 4294967296
  end

  def gamma_function(x)
    g = [
      1.0,
      0.5772156649015329,
      -0.6558780715202538,
      -0.420026350340952e-1,
      0.1665386113822915,
      -0.421977345555443e-1,
      -0.9621971527877e-2,
      0.7218943246663e-2,
      -0.11651675918591e-2,
      -0.2152416741149e-3,
      0.1280502823882e-3,
      -0.201348547807e-4,
      -0.12504934821e-5,
      0.1133027232e-5,
      -0.2056338417e-6,
      0.6116095e-8,
      0.50020075e-8,
      -0.11812746e-8,
      0.1043427e-9,
      0.77823e-11,
      -0.36968e-11,
      0.51e-12,
      -0.206e-13,
      -0.54e-14,
      0.14e-14
    ]

    r = 1.0

    return 1e308 if x > 171.0
    if x.is_a?(Fixnum) || x == x.to_i
      if x > 0
        ga = (2...x).inject(1.0) { |prod, i| prod * i }
      else
        1e308
      end
    else
      if x.abs > 1.0
        r = (1..(x.abs.to_i)).inject(1.0) { |prod, i| prod * (x.abs - i) }
        z = x.abs - x.abs.to_i
      else
        z = x
      end

      gr = g[24]
      23.downto(0).each do |i|
        gr = gr * z + g[i]
      end
      ga = 1.0 / (gr * z)
      if x.abs > 1
        ga *= r
        if x < 0
          ga = -Math::PI / (x * ga * Math.sin(Math::PI * x))
        end
      end
    end

    ga
  end
end

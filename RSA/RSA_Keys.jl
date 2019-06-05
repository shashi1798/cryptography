using Primes

function random(bits=256)
    return rand(BigInt(2)^bits:(BigInt(2)^(bits + 1) - BigInt(1)))
end

function random_prime(bits)
    p = random(bits)
    while !isprime(p)
        p = random(bits)
    end
    return p
end

function choose_e(phiN, bits)
    e = random(bits)
    while gcd(e, phiN) != 1
        e = random(bits)
    end
    return e
end

function cal_d(a, b)
    coeffs = Dict(a => [BigInt(1), BigInt(0)], b => [BigInt(0), BigInt(1)])
    a1, b1 = a, b
    y = a1 % b1
    x = div(a1 - y, b1)
    c = coeffs[a1] - x*coeffs[b1]
    coeffs[y] = c
    while y != 1
        a1 = b1
        b1 = y
        y = a1 % b1
        x = div(a1 - y, b1)
        c = coeffs[a1] - x*coeffs[b1]
        coeffs[y] = c
    end
    return c[2]
end

function main()
    print("Enter bits: ")
    bits = parse(Int, readline())
    p, q = random_prime(bits), random_prime(bits)
    N = BigInt(p) * BigInt(q)
    phiN = BigInt(p - 1) * BigInt(q - 1)
    e = choose_e(phiN, bits)
    k = 1
    d = cal_d(phiN, e)
    if d < 0
        d += phiN   
    end
    time_stamp = round(Int64, time() * 1000)
    open("key$time_stamp.txt", "w") do file
        write(file, "PrivateKey: $d\nPublicKey: $e\nSharedKey: $N")
    end
    println("key$time_stamp.txt file created")
end

main()
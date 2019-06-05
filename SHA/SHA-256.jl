
RotR(X, n) = UInt32(2^(32 - n)*(X % 2^n) + div(X, 2^n))

ShR(X, n) = div(X, UInt32(2^n))

C(X) = UInt32(4294967295 - X)

Ch(X, Y, Z) = xor(X&Y, (C(X))&Z)

Maj(X, Y, Z) = xor(X&Y, X&Z, Y&Z)

sigma0(X) = xor(RotR(X, 2), RotR(X, 13), RotR(X, 22))

sigma1(X) = xor(RotR(X, 6), RotR(X, 11), RotR(X, 25))

sig0(X) = xor(RotR(X, 7), RotR(X, 18), ShR(X, 3))

sig1(X) = xor(RotR(X, 17), RotR(X, 19), ShR(X, 10))

initialize_H() = UInt32.([
    0x6a09e667,
    0xbb67ae85,
    0x3c6ef372,
    0xa54ff53a,
    0x510e527f,
    0x9b05688c,
    0x1f83d9ab,
    0x5be0cd19
])

initialize_K() = UInt32.([
    0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5,
    0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
    0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
    0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
    0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc,
    0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
    0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
    0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
    0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
    0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
    0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3,
    0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
    0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5,
    0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
    0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
    0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
])

function print_block(block)
    index = 1
    for byte in block
        print(byte, " ")
        if index % 8 == 0
            println()
        end
        index += 1
    end
end

function create_block_array(data)
    len = length(data)
    message_length::Int64 = len * 8
    byte_array = UInt8.(collect(data))
    push!(byte_array, UInt8(0x80))
    len += 1
    while len % 64 != 56
        push!(byte_array, UInt8(0))
        len += 1
    end
    p::Int64 = 2^56
    for i = 1:8
        push!(byte_array, UInt8(div(message_length, p)))
        message_length = message_length % p
        p = div(p, 256)
        len += 1
    end
    number_of_blocks = div(len, 64)
    block_array = Array{Array{UInt8}}(undef, number_of_blocks)
    for i = 1:number_of_blocks
        block_array[i] = byte_array[1:64]
        byte_array = byte_array[65:end]
    end
    return block_array
end

function decompose_block(block)
    W = Array{UInt32}(undef, 64)
    index = 1
    for i = 1:4:64
        W[index] = UInt32(block[i] * 256^3 + block[i + 1] * 256*256 + block[i + 2] * 256 + block[i + 3])
        index += 1
    end
    while index <= 64
        W[index] = UInt32((sig1(W[index - 2]) + W[index - 7] + sig0(W[index - 15]) + W[index - 16]) % 4294967296)
        index += 1
    end
    return W
end

function main()
    print("Enter a text: ")
    text = readline()
    H = initialize_H()
    K = initialize_K()
    M = create_block_array(text)
    for block in M
        W = decompose_block(block)
        a, b, c, d, e, f, g, h = H
        for i = 1:64
            T1 = UInt32((h + sigma1(e) + Ch(e, f, g) + K[i] + W[i]) % 4294967296)
            T2 = UInt32((sigma0(a) + Maj(a, b, c)) % 4294967296)
            h = g
            g = f
            f = e
            e = UInt32((d + T1) % 4294967296)
            d = c
            c = b
            b = a
            a = UInt32((T1 + T2) % 4294967296)
        end
        H += [a, b, c, d, e, f, g, h]
    end
    print("Hash: ")
    print.(string.(H, base=16))
    println()
end

main()
#+feature dynamic-literals
package main

import fmt "core:fmt"
import os "core:os"

cartridge :: struct {
    entryPoint: [0x4]u8,
    nintendoLogo: [0x30]u8,
    title: [0x10]u8,
    manufactururCode: [0x4]u8,
    CGBFlag : [1]u8,
    licenseeCode: [0x2]u8,
    SGBFlag : [1]u8,
    cartridgeType : [1]u8,
    romSize : [1]u8,
    ramSize : [1]u8,
    destinationCode: [1]u8,
    oldLicenseeCode : [1]u8,
    maskRomVersion : [1]u8,
    headerChecksum: [1]u8,
    globalChecksum: [2]u8,

}

cart : cartridge = {
    nintendoLogo = { 0xCE, 0xED, 0x66, 0x66, 0xCC, 0x0D, 0x00, 0x0B, 0x03, 0x73, 0x00, 0x83, 0x00, 0x0C, 0x00, 0x0D, 0x00, 0x08, 0x11, 0x1F, 0x88,
    0x89, 0x00, 0x0E, 0xDC, 0xCC, 0x6E, 0xE6, 0xDD, 0xDD, 0xD9, 0x99, 0xBB, 0xBB, 0x67,
    0x63, 0x6E, 0x0E, 0xEC, 0xCC, 0xDD, 0xDC, 0x99, 0x9F, 0xBB, 0xB9, 0x33, 0x3E }
}

loadCartridge :: proc (locaction: string) {

    data, ok := os.read_entire_file(locaction, context.allocator)

    if !ok{
        fmt.println("Invalid file")
    }

    for b, index in data{
        memory[index] = b
    }

    for i in 0 ..< 0x4 {
        cart.entryPoint[i] = memory[0x100 + i]
    }

    for i in 0 ..< 0x10{
        mempos := memory[0x134 + i]
        if mempos == 0 {
            cart.title[i] = 126
            continue
        }

        cart.title[i] = mempos
    }

    for i in 0 ..< 0x4{
        cart.manufactururCode[i] = memory[0x13F + i]
    }

    cart.CGBFlag = memory[0x143]
    for i in 0 ..< 0x2{
        cart.licenseeCode[i] = memory[0x144 + i]
    }


    cart.SGBFlag = memory[0x146]
    cart.cartridgeType = memory[0x147]
    cart.romSize = memory[0x148]
    cart.ramSize = memory[0x149]
    cart.destinationCode = memory[0x14A]
    cart.oldLicenseeCode = memory[0x14B]
    cart.maskRomVersion = memory[0x14C]
    cart.headerChecksum = memory[0x14D]
    for i in 0 ..< 0x2{
        cart.globalChecksum[i] = memory[0x14E + i]
    }

}

newPublishersMap := map[string]string{
    "00" = "None",
    "01" = "Nintendo Research & Development 1",
    "08" = "Capcom",
    "13" = "EA (Electronic Arts)",
    "18" = "Hudson Soft",
    "19" = "B-AI",
    "20" = "KSS",
    "22" = "Planning Office WADA",
    "24" = "PCM Complete",
    "25" = "San-X",
    "28" = "Kemco",
    "29" = "SETA Corporation",
    "30" = "Viacom",
    "31" = "Nintendo",
    "32" = "Bandai",
    "33" = "Ocean Software/Acclaim Entertainment",
    "34" = "Konami",
    "35" = "HectorSoft",
    "37" = "Taito",
    "38" = "Hudson Soft",
    "39" = "Banpresto",
    "41" = "Ubi Soft1",
    "42" = "Atlus",
    "44" = "Malibu Interactive",
    "46" = "Angel",
    "47" = "Bullet-Proof Software2",
    "49" = "Irem",
    "50" = "Absolute",
    "51" = "Acclaim Entertainment",
    "52" = "Activision",
    "53" = "Sammy USA Corporation",
    "54" = "Konami",
    "55" = "Hi Tech Expressions",
    "56" = "LJN",
    "57" = "Matchbox",
    "58" = "Mattel",
    "59" = "Milton Bradley Company",
    "60" = "Titus Interactive",
    "61" = "Virgin Games Ltd.3",
    "64" = "Lucasfilm Games4",
    "67" = "Ocean Software",
    "69" = "EA (Electronic Arts)",
    "70" = "Infogrames5",
    "71" = "Interplay Entertainment",
    "72" = "Broderbund",
    "73" = "Sculptured Software6",
    "75" = "The Sales Curve Limited7",
    "78" = "THQ",
    "79" = "Accolade",
    "80" = "Misawa Entertainment",
    "83" = "lozc",
    "86" = "Tokuma Shoten",
    "87" = "Tsukuda Original",
    "91" = "Chunsoft Co.8",
    "92" = "Video System",
    "93" = "Ocean Software/Acclaim Entertainment",
    "95" = "Varie",
    "96" = "Yonezawa/s’pal",
    "97" = "Kaneko",
    "99" = "Pack-In-Video",
    "9H" = "Bottom Up",
    "A4" = "Konami (Yu-Gi-Oh!)",
    "BL" = "MTO",
    "DK" = "Kodansha"
}

oldPublisherMap := map[string]string {
    "00" = "None",
    "01" = "Nintendo",
    "08" = "Capcom",
    "09" = "HOT-B",
    "0A" = "Jaleco",
    "0B" = "Coconuts Japan",
    "0C" = "Elite Systems",
    "13" = "EA (Electronic Arts)",
    "18" = "Hudson Soft",
    "19" = "ITC Entertainment",
    "1A" = "Yanoman",
    "1D" = "Japan Clary",
    "1F" = "Virgin Games Ltd.3",
    "24" = "PCM Complete",
    "25" = "San-X",
    "28" = "Kemco",
    "29" = "SETA Corporation",
    "30" = "Infogrames5",
    "31" = "Nintendo",
    "32" = "Bandai",
    "33" = "Indicates that the New licensee code should be used instead.",
    "34" = "Konami",
    "35" = "HectorSoft",
    "38" = "Capcom",
    "39" = "Banpresto",
    "3C" = "Entertainment Interactive (stub)",
    "3E" = "Gremlin",
    "41" = "Ubi Soft1",
    "42" = "Atlus",
    "44" = "Malibu Interactive",
    "46" = "Angel",
    "47" = "Spectrum HoloByte",
    "49" = "Irem",
    "4A" = "Virgin Games Ltd.3",
    "4D" = "Malibu Interactive",
    "4F" = "U.S. Gold",
    "50" = "Absolute",
    "51" = "Acclaim Entertainment",
    "52" = "Activision",
    "53" = "Sammy USA Corporation",
    "54" = "GameTek",
    "55" = "Park Place13",
    "56" = "LJN",
    "57" = "Matchbox",
    "59" = "Milton Bradley Company",
    "5A" = "Mindscape",
    "5B" = "Romstar",
    "5C" = "Naxat Soft14",
    "5D" = "Tradewest",
    "60" = "Titus Interactive",
    "61" = "Virgin Games Ltd.3",
    "67" = "Ocean Software",
    "69" = "EA (Electronic Arts)",
    "6E" = "Elite Systems",
    "6F" = "Electro Brain",
    "70" = "Infogrames5",
    "71" = "Interplay Entertainment",
    "72" = "Broderbund",
    "73" = "Sculptured Software6",
    "75" = "The Sales Curve Limited7",
    "78" = "THQ",
    "79" = "Accolade15",
    "7A" = "Triffix Entertainment",
    "7C" = "MicroProse",
    "7F" = "Kemco",
    "80" = "Misawa Entertainment",
    "83" = "LOZC G.",
    "86" = "Tokuma Shoten",
    "8B" = "Bullet-Proof Software2",
    "8C" = "Vic Tokai Corp.16",
    "8E" = "Ape Inc.17",
    "8F" = "I’Max18",
    "91" = "Chunsoft Co.8",
    "92" = "Video System",
    "93" = "Tsubaraya Productions",
    "95" = "Varie",
    "96" = "Yonezawa19/S’Pal",
    "97" = "Kemco",
    "99" = "Arc",
    "9A" = "Nihon Bussan",
    "9B" = "Tecmo",
    "9C" = "Imagineer",
    "9D" = "Banpresto",
    "9F" = "Nova",
    "A1" = "Hori Electric",
    "A2" = "Bandai",
    "A4" = "Konami",
    "A6" = "Kawada",
    "A7" = "Takara",
    "A9" = "Technos Japan",
    "AA" = "Broderbund",
    "AC" = "Toei Animation",
    "AD" = "Toho",
    "AF" = "Namco",
    "B0" = "Acclaim Entertainment",
    "B1" = "ASCII Corporation or Nexsoft",
    "B2" = "Bandai",
    "B4" = "Square Enix",
    "B6" = "HAL Laboratory",
    "B7" = "SNK",
    "B9" = "Pony Canyon",
    "BA" = "Culture Brain",
    "BB" = "Sunsoft",
    "BD" = "Sony Imagesoft",
    "BF" = "Sammy Corporation",
    "C0" = "Taito",
    "C2" = "Kemco",
    "C3" = "Square",
    "C4" = "Tokuma Shoten",
    "C5" = "Data East",
    "C6" = "Tonkin House",
    "C8" = "Koei",
    "C9" = "UFL",
    "CA" = "Ultra Games",
    "CB" = "VAP, Inc.",
    "CC" = "Use Corporation",
    "CD" = "Meldac",
    "CE" = "Pony Canyon",
    "CF" = "Angel",
    "D0" = "Taito",
    "D1" = "SOFEL (Software Engineering Lab)",
    "D2" = "Quest",
    "D3" = "Sigma Enterprises",
    "D4" = "ASK Kodansha Co.",
    "D6" = "Naxat Soft14",
    "D7" = "Copya System",
    "D9" = "Banpresto",
    "DA" = "Tomy",
    "DB" = "LJN",
    "DD" = "Nippon Computer Systems",
    "DE" = "Human Ent.",
    "DF" = "Altron",
    "E0" = "Jaleco",
    "E1" = "Towa Chiki",
    "E2" = "Yutaka # Needs more info",
    "E3" = "Varie",
    "E5" = "Epoch",
    "E7" = "Athena",
    "E8" = "Asmik Ace Entertainment",
    "E9" = "Natsume",
    "EA" = "King Records",
    "EB" = "Atlus",
    "EC" = "Epic/Sony Records",
    "EE" = "IGS",
    "F0" = "A Wave",
    "F3" = "Extreme Entertainment",
    "FF" = "LJN"
}

cardinfo :: struct {
    title : string,
    newPublisher : string,
    oldPublisher : string
}








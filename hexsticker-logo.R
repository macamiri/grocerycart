# Load packages
pacman::p_load(hexSticker, sysfonts, magick, magrittr)

# Load in image to use
logo <- image_read(here::here("grocerycart-icon2.png"))

# See available fonts
font_files() %>% tibble::tibble() %>% View()

# Load in font to use
font_add("Raleway ExtraBold", "Raleway-ExtraBoldItalic.ttf")

# Create hexsticker
sticker(subplot = logo,
        package = "grocerycart",
        s_x = 1,
        s_y = .755,
        s_width = 1.14,
        s_height = 1.14,
        p_x = 1,
        p_y = 1.42,
        p_color = "#081C15",
        p_family = "Raleway ExtraBold",
        p_size = 20,
        h_size = 1.45,
        h_fill = "#74C69D",
        h_color = "#52B788",
        url = "https://github.com/moamiristat/grocerycart",
        u_size = 3.45,
        u_x = 1,
        u_y = .06,
        u_color = "#2D6A4F",
        dpi = 300,
        filename = "grocerycart-hexsticker.png")


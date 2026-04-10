library(hexSticker)
imgurl <- system.file("man/figures/logo.png")

s <- sticker("man/figures/logo.png",
             package="logrittr", p_size=25, s_x=1, s_y=0.8, 
             s_width=0.7, s_height=0.5,
             filename="man/figures/logo2.png", 
             h_color = "cornflowerblue", 
             h_fill="#2c2828",
             h_size = 2.2,
             p_color = "cornflowerblue", 
             dpi = 300)
s

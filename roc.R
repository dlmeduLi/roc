library("ggplot2")
library("data.table")

PlotRoc <- function(file.name) {
  asm.data <- fread(file.name, header = FALSE)
  setnames(asm.data, c("sample", "asm", "repeats", "imprint", "random"))
  asm.data$total <- with(asm.data, asm + repeats + imprint)
  asm.data$found <- with(asm.data, asm + imprint)
  asm.data$fdr <- with(asm.data, random / found)
  print(asm.data)
  ggplot(asm.data, aes(x = fdr, y = imprint)) + geom_point() + geom_line()
}

#PlotRoc("~/work/roc/origin.asm600.csv")
#PlotRoc("~/work/roc/origin.ratio01.csv")

PlotRoc("~/work/roc/asm/ratio0.2.final.csv")

file.name <- "~/work/roc/asm/ratio0.1.final.csv"
asm.data <- read.csv(file.name, header = TRUE, sep = " ")
asm.data$total <- with(asm.data, asm + repeats + imprint)
asm.data$found <- with(asm.data, asm + imprint)
asm.data$fdr <- with(asm.data, random / found)
print(asm.data)
ggplot(asm.data[1:8,], aes(x = fdr, y = imprint)) + geom_point() + geom_line() +
  xlab("FDR") + ylab("# of known imprinted genes recovered") + 
  labs(title = "ROC-like curve for method evaluation") +
  theme_bw() + ylim(15, 40) +
  theme(
    panel.border = element_rect(color = "black"),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank()
  )
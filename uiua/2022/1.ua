ReadFileFromFirstEl ← &fras ! ⊡ 1
SplitByChar ← ⊜□≠,
SplitByString ← ⊜□¬/+∺↻¯⇡∶⊙⧻⬚0↙⊙⌕∶⊙'⧻.,,
SumStringArray ← ∧(|2 +parse!∶) 0

ReadFileFromFirstEl &args

SplitByString "\n\n"
∵(□ SplitByChar @\n !∘)
∵(|1 SumStringArray!)

/+↙3⊏⇌⌂.∶/↥.

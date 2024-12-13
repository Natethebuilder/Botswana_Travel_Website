breed [people person]

turtles-own [
  group                      ; Group A to F, representing ethnic groups
  prejudice                  ; Prejudice level towards other groups (0 to 100)
  economic-status            ; Economic status of each agent (0-100 scale)
  location                   ; Neighborhood or area where the agent lives
  age                        ; Age for youth socialization
  ptr                        ; Probability to reproduce
  cooperate-with-same?       ; Cooperation strategy with the same group
  cooperate-with-different?  ; Cooperation strategy with other groups
]

globals [
  meet                             ; Total interactions this turn
  meet-agg                         ; Total interactions through the run
  coopown                          ; Cooperation with same group this turn
  coopown-agg                      ; Total cooperation with same group through the run
  coopother                        ; Cooperation with other groups this turn
  coopother-agg                    ; Total cooperation with other groups through the run
  defother                         ; Defection with other groups this turn
  defother-agg                     ; Total defection with other groups through the run
  defown                           ; Defection within the same group this turn
  defown-agg                       ; Total defection within the same group through the run

  interventionStartTime            ; Time when interventions start
  interaction-history  ;; Tracks recent interactions to stabilize cooperation/defection balance

  ; Intensity variables for each intervention
  legalPolicyIntensity             ; Intensity of legal and policy reforms
  trainingIntensity                ; Intensity of diversity/anti-prejudice training
  communityEventIntensity          ; Intensity of community-based events
  economicIncentiveIntensity       ; Intensity of economic incentives
  sharedResourceIntensity          ; Intensity of shared resource management
  youthSocializationIntensity      ; Intensity of youth socialization

  avg-prejudice-group-A
  avg-prejudice-group-B
  avg-prejudice-group-C
  avg-prejudice-group-D
  avg-prejudice-group-E

  current-environment              ; Tracks current environment type
]


; ------------------------------
; Setup the simulation
to setup
  clear-all
  setup-environment
  setup-variables
  setup-people
  reset-ticks
end


; ------------------------------
; Setup the environment based on environmentType
to setup-environment
  if environmentType = 0 [ ; Fully Segregated
    let region-size floor (max-pxcor / 5) ; Calculate size of each region

    ask patches [
      if pxcor < region-size [ set pcolor pink ] ; Region for Group A
      if pxcor >= region-size and pxcor < region-size * 2 [ set pcolor sky ] ; Region for Group B
      if pxcor >= region-size * 2 and pxcor < region-size * 3 [ set pcolor lime ] ; Region for Group C
      if pxcor >= region-size * 3 and pxcor < region-size * 4 [ set pcolor yellow ] ; Region for Group D
      if pxcor >= region-size * 4 [ set pcolor orange ] ; Region for Group E
    ]

    ; Place agents in their respective regions
    ask people [
      if group = "A" [ move-to one-of patches with [pcolor = pink] ]
      if group = "B" [ move-to one-of patches with [pcolor = sky] ]
      if group = "C" [ move-to one-of patches with [pcolor = lime] ]
      if group = "D" [ move-to one-of patches with [pcolor = yellow] ]
      if group = "E" [ move-to one-of patches with [pcolor = orange] ]
    ]
  ]

  if environmentType = 1 [ ; Fully Mixed
    ask patches [ set pcolor gray ]
    ask people [ move-to one-of patches ]
  ]

  if environmentType = 2 [ ; Partial Segregation
    let region-size floor (max-pxcor / 5)

    ask patches [
      if pxcor < region-size [ set pcolor pink ]
      if pxcor >= region-size and pxcor < region-size * 2 [ set pcolor sky ]
      if pxcor >= region-size * 2 and pxcor < region-size * 3 [ set pcolor lime ]
      if pxcor >= region-size * 3 and pxcor < region-size * 4 [ set pcolor yellow ]
      if pxcor >= region-size * 4 [ set pcolor orange ]
    ]

    ; Assign agents probabilistically to segregated or free movement
    ask people [
      let stay-segregated random-float 100 < 70
      if stay-segregated [
        if group = "A" [ move-to one-of patches with [pcolor = pink] ]
        if group = "B" [ move-to one-of patches with [pcolor = sky] ]
        if group = "C" [ move-to one-of patches with [pcolor = lime] ]
        if group = "D" [ move-to one-of patches with [pcolor = yellow] ]
        if group = "E" [ move-to one-of patches with [pcolor = orange] ]
      ]
      if not stay-segregated [ move-to one-of patches ] ; Free movement for 30%
    ]
  ]
end


; ------------------------------
; Setup variables and agents
to setup-variables
  set meet 0
  set meet-agg 0
  set coopown 0
  set coopown-agg 0
  set coopother 0
  set coopother-agg 0
  set defother 0
  set defother-agg 0
  set defown 0
  set defown-agg 0
  set interaction-history 0  ;; Reset interaction history
end


to setup-people
  create-people 100 [
    setxy random-xcor random-ycor
    set group one-of ["A" "B" "C" "D" "E"]
    set prejudice random 80 + 20 ;; Initialize prejudice between 20 and 100
    set economic-status random-float 100
    set age random 100
    set ptr 0.5
    set cooperate-with-same? (random 2 = 0)
    set cooperate-with-different? (random 2 = 0)
  ]
  update-shape
end



; ------------------------------
; Update shapes dynamically
to update-shape
  ask people [
    if group = "A" [ set shape "circle" set color red ]       ; Group A → Pink region
    if group = "B" [ set shape "square" set color blue ]      ; Group B → Sky region
    if group = "C" [ set shape "triangle" set color green ]   ; Group C → Lime region
    if group = "D" [ set shape "star" set color black ]       ; Group D → Yellow region
    if group = "E" [ set shape "person" set color violet ]    ; Group E → Orange region
  ]
end


; ------------------------------
to go
  ;; Sync sliders to global variables
  set interventionStartTime slider_interventionStartTime
  set legalPolicyIntensity slider_legalPolicyIntensity
  set trainingIntensity slider_trainingIntensity
  set communityEventIntensity slider_communityEventIntensity
  set economicIncentiveIntensity slider_economicIncentiveIntensity
  set sharedResourceIntensity slider_sharedResourceIntensity
  set youthSocializationIntensity slider_youthSocializationIntensity

  ;; Movement logic based on environment
  if environmentType = 0 [
    ;; Fully Segregated: Confinement unless interventions allow movement
    if communityEventIntensity > 0 or sharedResourceIntensity > 0 or youthSocializationIntensity > 0 [
      ask people [ move-based-on-intervention ]
    ]
    if communityEventIntensity = 0 and sharedResourceIntensity = 0 and youthSocializationIntensity = 0 [
      ask people [ move-within-region ]
    ]
  ]
  if environmentType = 1 [
    ;; Fully Mixed: Free movement
    ask people [ move-around ]
  ]
  if environmentType = 2 [
    ;; Partial Segregation: Some free movement, some confined
    ask people [ move-partially ]
  ]

  ;; Clear stats
  clear-stats

  ;; Perform interactions and update prejudice
  ask people [
    interact
    update-prejudice
  ]

  ;; Implement interventions
  implement-interventions

  ;; Update statistics
  update-stats

  ;; Increment tick
  tick
end




; ------------------------------

; Movement logic for free movement
to move-around
  ;; Agents move freely, representing fully mixed environments
  rt random 360
  fd 1
end
to move-based-on-intervention
  ;; Community events encourage visible movement across regions
  if communityEventIntensity > 0 [
    let step-size (communityEventIntensity / 10) + 1 ;; Larger steps for higher intensity
    rt random 360
    fd step-size
    stop
  ]

  ;; Shared resource management also encourages inter-group movement
  if sharedResourceIntensity > 0 [
    let step-size (sharedResourceIntensity / 10) + 1
    rt random 360
    fd step-size
    stop
  ]

  ;; Youth socialization allows movement for younger agents
  if youthSocializationIntensity > 0 and age < 18 [
    let step-size (youthSocializationIntensity / 10) + 1
    rt random 360
    fd step-size
    stop
  ]

  ;; If no interventions apply, stay within assigned region
  move-within-region
end


; Movement logic for confined movement within regions
to move-within-region
  ;; Determine the region color based on the group
  let region-color
    ifelse-value (group = "A") [pink]
    [ifelse-value (group = "B") [sky]
    [ifelse-value (group = "C") [lime]
    [ifelse-value (group = "D") [yellow]
    [orange]]]]

  ;; Ensure agent stays within assigned region
  if pcolor != region-color [
    move-to one-of patches with [pcolor = region-color]
  ]

  ;; Small random movement within region
  rt random 90
  fd 1

  ;; Double-check confinement
  if pcolor != region-color [
    move-to one-of patches with [pcolor = region-color]
  ]
end


; Movement logic for partially segregated environments
; Movement logic for partially segregated environments
to move-partially
  ;; 70% of agents stay confined, 30% move freely
  let free-movement-probability 30  ;; Percentage of agents allowed to move freely
  if random-float 100 < free-movement-probability [
    move-around  ;; Free movement for 30% of agents
  ]
  if random-float 100 >= free-movement-probability [
    move-within-region  ;; Confined movement for 70% of agents
  ]
end


; ------------------------------
; Interaction logic for cooperation and defection
; Interaction logic for cooperation and defection
to interact
  let neighbor one-of turtles in-radius 1
  if neighbor != nobody [
    let interaction-group [group] of neighbor
    let interaction-outcome 0 ;; Default to defection

    ;; Determine if interventions are active
    let forced-interventions-active? (
      youthSocializationIntensity > 0 or
      sharedResourceIntensity > 0 or
      communityEventIntensity > 0
    )

    ;; Inter-group interactions: Cooperation depends on interventions, prejudice, and probabilities
    if group != interaction-group [
      let inter-group-coop-probability (
        (legalPolicyIntensity / 100 * 0.2) +  ;; Legal reforms support cooperation
        (trainingIntensity / 100 * 0.3) +    ;; Training builds inter-group trust
        (sharedResourceIntensity / 100 * 0.3) + ;; Shared resources foster cooperation
        (communityEventIntensity / 100 * 0.2) - ;; Prejudice reduces cooperation likelihood
        (prejudice / 100 * 0.4)               ;; High prejudice negatively impacts cooperation
      )
      if random-float 100 < inter-group-coop-probability * 100 [
        set interaction-outcome 1 ;; Cooperation
      ]
    ]

    ;; Intra-group interactions: High likelihood of cooperation
    if group = interaction-group [
      let intra-group-coop-probability 70 + (trainingIntensity / 100 * 20)
      if random-float 100 < intra-group-coop-probability [
        set interaction-outcome 1 ;; Cooperation
      ]
    ]

    ;; Update stats and prejudice
    if interaction-outcome = 1 [
      if group = interaction-group [ set coopown coopown + 1 ]
      if group != interaction-group [ set coopother coopother + 1 ]
      set prejudice max list 0 (prejudice - random-float 2) ;; Cooperation reduces prejudice
    ]
    if interaction-outcome = 0 [
      if group = interaction-group [ set defown defown + 1 ]
      if group != interaction-group [ set defother defother + 1 ]
      set prejudice min list 100 (prejudice + random-float 3) ;; Defection increases prejudice
    ]
  ]
end



; ------------------------------
; Implement all interventions
to implement-interventions
  if ticks >= interventionStartTime [
    ask people [
      ;; Legal and policy reforms
      if prejudice > 50 [
        set prejudice prejudice * (1 - (legalPolicyIntensity / 100 * 0.4))
      ]

      ;; Training
      set prejudice prejudice * (1 - (trainingIntensity / 100 * 0.6))

      ;; Community events (inter-group proximity effect)
      if pcolor = lime or pcolor = yellow [
        let neighbor one-of other turtles in-radius 2
        if neighbor != nobody and [group] of neighbor != group [
          set prejudice prejudice * (1 - (communityEventIntensity / 100 * 0.3))
        ]
      ]

      ;; Economic incentives
      if economic-status < 50 [
        set prejudice prejudice * (1 - (economicIncentiveIntensity / 100 * 0.3))
      ]

      ;; Shared resources
      set prejudice prejudice * (1 - (sharedResourceIntensity / 100 * 0.2))

      ;; Youth socialization
      if age < 18 [
        set prejudice prejudice * (1 - (youthSocializationIntensity / 100 * 0.5))
      ]
    ]
  ]
end




; ------------------------------


; Reset counters each tick
to clear-stats
  set meet 0
  set coopown 0
  set coopother 0
  set defother 0
  set defown 0
end


; ------------------------------
; Update statistics
; Update statistics
to update-stats
  set meet-agg meet-agg + meet
  set coopown-agg coopown-agg + coopown
  set coopother-agg coopother-agg + coopother
  set defother-agg defother-agg + defother
  set defown-agg defown-agg + defown

  if any? people with [group = "A"] [
    set avg-prejudice-group-A mean [prejudice] of people with [group = "A"]
  ]
  if not any? people with [group = "A"] [ set avg-prejudice-group-A 0 ]

  if any? people with [group = "B"] [
    set avg-prejudice-group-B mean [prejudice] of people with [group = "B"]
  ]
  if not any? people with [group = "B"] [ set avg-prejudice-group-B 0 ]

  if any? people with [group = "C"] [
    set avg-prejudice-group-C mean [prejudice] of people with [group = "C"]
  ]
  if not any? people with [group = "C"] [ set avg-prejudice-group-C 0 ]

  if any? people with [group = "D"] [
    set avg-prejudice-group-D mean [prejudice] of people with [group = "D"]
  ]
  if not any? people with [group = "D"] [ set avg-prejudice-group-D 0 ]

  if any? people with [group = "E"] [
    set avg-prejudice-group-E mean [prejudice] of people with [group = "E"]
  ]
  if not any? people with [group = "E"] [ set avg-prejudice-group-E 0 ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13.0
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
14
24
78
57
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
83
23
146
56
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
0
61
205
94
slider_interventionStartTime
slider_interventionStartTime
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
0
96
196
129
slider_legalPolicyIntensity
slider_legalPolicyIntensity
0
10
0.0
1
1
NIL
HORIZONTAL

SLIDER
0
133
177
166
slider_trainingIntensity
slider_trainingIntensity
0
10
0.0
1
1
NIL
HORIZONTAL

SLIDER
668
24
894
57
slider_communityEventIntensity
slider_communityEventIntensity
0
10
0.0
1
1
NIL
HORIZONTAL

SLIDER
665
60
903
93
slider_economicIncentiveIntensity
slider_economicIncentiveIntensity
0
10
0.0
1
1
NIL
HORIZONTAL

SLIDER
672
97
897
130
slider_sharedResourceIntensity
slider_sharedResourceIntensity
0
10
6.0
1
1
NIL
HORIZONTAL

SLIDER
672
143
906
176
slider_youthSocializationIntensity
slider_youthSocializationIntensity
0
10
0.0
1
1
NIL
HORIZONTAL

MONITOR
685
187
898
232
Total cooperation within same group
coopown-agg
17
1
11

MONITOR
4
220
215
265
Total cooperation with other groups
coopother-agg
17
1
11

MONITOR
4
275
207
320
Total defections with other groups
defother-agg
17
1
11

MONITOR
19
326
123
371
overall prejudice
mean [prejudice] of people
2
1
11

MONITOR
22
381
125
426
economic-status
mean [economic-status] of people
2
1
11

MONITOR
683
251
794
296
prejudice group A
mean [prejudice] of people with [group = \"A\"]
2
1
11

MONITOR
686
302
796
347
prejudice group B
mean [prejudice] of people with [group = \"B\"]
2
1
11

MONITOR
688
348
799
393
prejudice group C
mean [prejudice] of people with [group = \"C\"]
2
1
11

MONITOR
690
397
801
442
prejudice group D
mean [prejudice] of people with [group = \"D\"]
2
1
11

MONITOR
691
449
801
494
prejudice group E
mean [prejudice] of people with [group = \"E\"]
2
1
11

SLIDER
13
471
185
504
environmentType
environmentType
0
2
0.0
1
1
NIL
HORIZONTAL

MONITOR
11
178
201
223
Total defections with own group
defown-agg
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="SharedResourceIntensityEffects" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>coopother-agg</metric>
    <metric>defother-agg</metric>
    <metric>coopown-agg</metric>
    <metric>mean [prejudice] of people</metric>
    <metric>mean [prejudice] of people with [group = "A"]</metric>
    <metric>mean [prejudice] of people with [group = "B"]</metric>
    <metric>mean [prejudice] of people with [group = "C"]</metric>
    <metric>mean [prejudice] of people with [group = "D"]</metric>
    <metric>mean [prejudice] of people with [group = "E"]</metric>
    <enumeratedValueSet variable="environmentType">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_sharedResourceIntensity">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_legalPolicyIntensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_communityEventIntensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_youthSocializationIntensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_trainingIntensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_economicIncentiveIntensity">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="LegalPolicyIntensity" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>coopother-agg</metric>
    <metric>defother-agg</metric>
    <metric>coopown-agg</metric>
    <metric>mean [prejudice] of people</metric>
    <metric>mean [prejudice] of people with [group = "A"]</metric>
    <metric>mean [prejudice] of people with [group = "B"]</metric>
    <metric>mean [prejudice] of people with [group = "C"]</metric>
    <metric>mean [prejudice] of people with [group = "D"]</metric>
    <metric>mean [prejudice] of people with [group = "E"]</metric>
    <enumeratedValueSet variable="environmentType">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_sharedResourceIntensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_legalPolicyIntensity">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_communityEventIntensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_youthSocializationIntensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_trainingIntensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_economicIncentiveIntensity">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="CommunityEventIntensity" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>coopother-agg</metric>
    <metric>defother-agg</metric>
    <metric>coopown-agg</metric>
    <metric>mean [prejudice] of people</metric>
    <metric>mean [prejudice] of people with [group = "A"]</metric>
    <metric>mean [prejudice] of people with [group = "B"]</metric>
    <metric>mean [prejudice] of people with [group = "C"]</metric>
    <metric>mean [prejudice] of people with [group = "D"]</metric>
    <metric>mean [prejudice] of people with [group = "E"]</metric>
    <enumeratedValueSet variable="environmentType">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_sharedResourceIntensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_legalPolicyIntensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_communityEventIntensity">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_youthSocializationIntensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_trainingIntensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_economicIncentiveIntensity">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="YouthSocializationIntensity" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>coopother-agg</metric>
    <metric>defother-agg</metric>
    <metric>coopown-agg</metric>
    <metric>mean [prejudice] of people</metric>
    <metric>mean [prejudice] of people with [group = "A"]</metric>
    <metric>mean [prejudice] of people with [group = "B"]</metric>
    <metric>mean [prejudice] of people with [group = "C"]</metric>
    <metric>mean [prejudice] of people with [group = "D"]</metric>
    <metric>mean [prejudice] of people with [group = "E"]</metric>
    <enumeratedValueSet variable="environmentType">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_sharedResourceIntensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_legalPolicyIntensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_communityEventIntensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_youthSocializationIntensity">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_trainingIntensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_economicIncentiveIntensity">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="TrainingIntensity" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>coopother-agg</metric>
    <metric>defother-agg</metric>
    <metric>coopown-agg</metric>
    <metric>mean [prejudice] of people</metric>
    <metric>mean [prejudice] of people with [group = "A"]</metric>
    <metric>mean [prejudice] of people with [group = "B"]</metric>
    <metric>mean [prejudice] of people with [group = "C"]</metric>
    <metric>mean [prejudice] of people with [group = "D"]</metric>
    <metric>mean [prejudice] of people with [group = "E"]</metric>
    <enumeratedValueSet variable="environmentType">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_sharedResourceIntensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_legalPolicyIntensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_communityEventIntensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_youthSocializationIntensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_trainingIntensity">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_economicIncentiveIntensity">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="EconomicIncentiveIntensity" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>coopother-agg</metric>
    <metric>defother-agg</metric>
    <metric>coopown-agg</metric>
    <metric>mean [prejudice] of people</metric>
    <metric>mean [prejudice] of people with [group = "A"]</metric>
    <metric>mean [prejudice] of people with [group = "B"]</metric>
    <metric>mean [prejudice] of people with [group = "C"]</metric>
    <metric>mean [prejudice] of people with [group = "D"]</metric>
    <metric>mean [prejudice] of people with [group = "E"]</metric>
    <enumeratedValueSet variable="environmentType">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_sharedResourceIntensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_legalPolicyIntensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_communityEventIntensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_youthSocializationIntensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_trainingIntensity">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slider_economicIncentiveIntensity">
      <value value="0"/>
      <value value="1"/>
      <value value="2"/>
      <value value="3"/>
      <value value="4"/>
      <value value="5"/>
      <value value="6"/>
      <value value="7"/>
      <value value="8"/>
      <value value="9"/>
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@

#!/bin/bash
echo "<!DOCTYPE html>
<title>Snek</title>
<meta charset=\"utf-8\">
<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
<link rel=\"stylesheet\" href=\"style.css\">

<div style=\"padding-bottom: .7rem; font-size: .75rem;\">
Snek v1.0
&nbsp;&nbsp;&nbsp;&nbsp;
𝅘𝅥𝅮
<a href=\"#\" id=\"sfx-on\">on</a>
<a href=\"#\" id=\"sfx-off\">off</a>
&nbsp;&nbsp;&nbsp;&nbsp;
music by
<a href="https://www.youtube.com/@canaldohector" target="blank">MORC</a>
&nbsp;&nbsp;&nbsp;&nbsp;
<a href=\"https://nanom.neocities.org\" target=\"_blank\">
nanom's website
</a>
</div>

<canvas id=\"game\" width=\"480\" height=\"288\"></canvas>
<div>Score: <span id=\"score-el\">0</span></div>
<div id=\"game-over-el\" style=\"display: none;\">
☹ GAME OVER. Press space to respawn.
</div>

<audio src=\"sfx/katyusha3.ogg\" id=\"bgm\" loop></audio>
<audio src=\"sfx/nom.ogg\" id=\"sfx-nom\"></audio>
<audio src=\"sfx/death.ogg\" id=\"sfx-death\"></audio>

<script src=\"biwascheme.js\">
$(cat game.scm)
</script>" > index.html


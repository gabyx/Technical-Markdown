# Konvexe Probleme

@import "/includes/Math.md"

<div style="display:none;">
$$
\newcommand{\set}[1]{\mathcal{#1}}
\newcommand{\prox}[1]{\mathbf{prox}_{\set{C}}}
\DeclareMathOperator*{\argmin}{argmin}
\newcommand{\ncone}[1]{\mathcal{N}_{\set{#1}}}
\newcommand{\indf}[1]{I_{\set{#1}}}
$$
</div>

In diesem Abschnitt geht es darum ein besseres Verständnis zu geben über Algorithmen und Konzepte welche zum Beispiel bei der $2$d-/$3$d-Kollisionsdetektion oder in Optimierungs-Algorithmen genutzt werden. Die Erklärungen sind eine stärkere und vereinfachte Zusammenfassung aus dem [Kapitel 6: *Convex Optimization*](http://dx.doi.org/10.3929/ethz-a-010662262).
Dieses Kapitel möchte nicht mathematisch abschliessend sein, sondern lediglich (nach der Ansicht des Autors) ein paar wichtige Grundkonzepte vermitteln, welche einen wunderbaren Einstieg in dieses Thema geben. Die erwähnten Konzepte sind in der generellsten Form der konvexen Analysis zu finden und können sehr wohl als die wichtigsten Standbeine verinnerlicht werden. Auf Beweise wird bewusst verzichtet. Es wird versucht die mathematischen Definitionen anschaulich zu erklären.

Das Vorhandensein eines *konvexen* Optimierungsproblems oder auch einer *konvexen Menge* beim Lösen eines Problems in $3$D, oder auch mehr Dimensionen, erlaubt es, auf eine Fülle von mathematisch sehr etablierten Definitionen und Konzepte aus der *konvexen Analysis* zurückzugreifen. Diese schon fast 50-jährige Theorie ist sehr fundiert und ein abgeschlossenes Untergebiet in der Mathematik.

Die *konvexe Analysis* ist ein Grenzgebiet von *Geometrie*, *Analysis* und *Funktionalanalysis*, das sich mit den Eigenschaften **konvexer Mengen** und **konvexer Funktionen** befaßt und Anwendungen sowohl in der reinen Mathematik besitzt (von Existenzsätzen in der Theorie der Differential- und Integralgleichungen bis zum Gitterpunktsatz von Minkowski in der Zahlentheorie) als auch in Bereichen wie der mathematischen Ökonomie und den Ingenieurswissenschaften, wo man es oft mit Optimierungs- und Gleichgewichtsproblemen zu tun hat. Als einschlägige Referenz auf diesem Gebiet sei hier mal das Standardwerk [*Convex Analysis*]() von R. Tyrell Rockefeller gegeben.

## Konvexe Menge
Eine Menge $\set{C} \subseteq V$, also ein Teilmenge eines Vektorraums $V$, wird **konvex** genannt, falls und nur falls
$$
\begin{align}
    \lambda \v{a} + (1-\lambda) \v{b} \in \set{C} \quad \forall \v{a},\v{b} \in \set{C}, \ \lambda \in [0,1] \ .
\end{align}
$$
gilt.
Das heisst alle Punkte auf einer geraden Linie zwischen zwei beliebigen Punkten aus der Menge $\set{C}$ müssen **auch** in dieser Menge liegen damit es **konvex** ist. Stellt man sich eine Banane vor oder eine Oberfläche eines $3$d-Würfels, dann erfüllen diese Mengen das Kriterium nicht. Ein ausgefülltes $2$d-Rechteck , ein gefüllter $3$d-Würfel oder eine gefüllte Kugel jedoch schon.
Eine **konvexe* Menge ist eine Teilmenge eines Vektorraums. Ein Beispiel ist der euklidische Raum $\mathbb{E}^3$ in $3$D.

Man interessiert sich nun zum Beispiel für die Projektion eines Punktes $\v{x}$ auf ein konvexe Menge $\set{C}$. Die Projektion sollte so sein, dass der Abstand zwischen dem Punkt $\v{x}$ und dem projezierten Punkt $\v{y} \in \set{C}$ **minimal** ist.

Der Abstand wird über eine Metrik $d(\v{x},\v{y}) \geq 0$ definiert - die *Distanzfunktion*. Der euklidische Vektorraum $\mathbb{E}^3$ ist ein Vektorraum mit einer Metrik und ist daher ein *metrischer Raum*. Das Standard-Skalarprodukt $\v{x}^\transp \v{y}$ im euklidischen Raum $\mathbb{E}^3$ induziert direkt die Standardnorm $\norm{\v{x}}_2 := \sqrt{\v{x}^\transp \v{x}} \geq 0$. Diese wiederum induziert direkt die Metrik
$$
\begin{align}
d(\v{x},\v{y}) := \norm{\v{x} - \v{y}}_2.
\end{align}
$$
Wir können somit über die Metrik $d(\v{x},\v{y})$ die Länge zwischen zwei Vektoren $\v{x},\v{y} \in \mathbb{E}^3$ berechnen.

## Proximaler Punkt

Mit der Metrik, also unserem Lineal zum Messen von Distanzen, lässt sich nun die Projektion $\prox{C}(\v{p})$ eines Punktes $\v{p}$ mit minimaler Distanz auf eine konvexe Menge $\set{C}$ relativ leicht definieren zu
$$
\begin{align}
\prox{C}(\v{p}) :=  \underset{\v{x} \ \in \ \set{C}}{\argmin} \norm{\v{x} - \v{p}}_2.
\end{align}
$$
Das heisst $\prox{C}(\v{p})$ minimiert den Punkt $\v{x}$ in der Menge $\set{C}$ so, dass sein Abstand zu $\v{p}$ minimal ist.

## Normalkegel

Eines der **wichtigsten** Konzept der konvexen Analysis ist die des **Normalkegels**. Wie der Name schon sagt, handelt es sich um einen Kegel welcher durch Normalenvektoren auf der Oberfläche einer konvexen Menge aufgespannt wird. Wir geben hier direkt die Definition und sehen im Anschluss wie sich dieser Kegel visualisiert:

Ein Normalkegel $\ncone{C}$ auf ein konvexes Set $\set{C}$ im Punkt $\v{x} \in \set{C}$ ist definert als
$$
\begin{align}
    \ncone{C}(\v{x}) := \left\{ \v{y} \ | \ \v{y}^\transp(\v{x}^* - \v{x}) \leq 0, \quad \forall \v{x}^* \in \set{C} \right\}
\end{align}
$$
Das ist nun ein wenig kryptisch, heisst jedoch nichts anderes als folgendes:
Der Normalkegel $\ncone{C}(\v{x})$ besteht aus allen Vektoren (das wäre $\v{y}$) ausgehend von $\v{x}$ welche mit **allen** Vektoren welche vom Punkt $\v{x}$ in die Menge $\set{C}$ zeigen (das wäre $\v{x}^* - \v{x}$), einen **stumpfen** Winkel bilden (das wäre das Skalatprodukt mit $\leq 0$).
Der Ursprung der Menge $\ncone{C}(\v{x})$ ist im Punkt $\v{x}$.

Das folgende Bild visualisiert für eine konvexe Menge $\set{C}$ die verschiedenen Normalkegel.

<div class="img-with-caption">
    <img src="/files/NormalKegel.svg" style="max-width:400px;width:80%"/>
    <div class="caption" id="nomal-cone-vis">Normalkegel an die Punkte $\v{x}$, $\v{y}$ und $\v{z}$. Der Normalkegel an einen innerhalb der Menge $\set{C}$ liegenden Punkt $\v{z}$ degeneriert zum $\v{0}$-Vektor. Der Vektor $\v{v}$ ist in der Menge des Normalkegels an $\v{x}$.</div>
</div>

## Zusammenhang von Normalkegel und Proximaler Punkt

Man fragt sich natürlich nun: *Was bringen uns diese mathematische Definitionen?*

Es stellt sich heraus, dass es einen Zusammenhang gibt zwischen $\prox{C}$ und $\ncone{C}$ welcher extremst nützlich ist und heute im Feld der konvexen Optimierung, beim Machine-Learning, in der Starrkörper-Mechanik (Starrkörper-Simulationen und Physics-Engines in Games) oder auch in der Kollisionsdetektion (GJK Algorithmus) durch projektive Iterationen direkte Anwendung findet.

Der Zusammenhang ist wie folgt:
$$
\begin{align}
\v{y} \in \ncone{C}(\v{x}) \quad \Leftrightarrow \quad \v{x} = \prox{C}(\v{x} + \v{y})
\label{eq-prox-to-ncone}
\end{align}
$$
Das heisst, eine Normalkegel-*Inklusion* (die Relation $\v{a} \in \set{B}$ wird *Mengen-Inklusion* genannt) ist direkt an eine **implizite** *projektive* Gleichung gekoppelt.

Damit lässt sich nun ein interessanter wichtiget Fakt ableiten.
Aus der [Visualisierung](#nomal-cone-vis) entnehmen wir, dass $\v{p}-\v{x}$ in der Menge $\ncone{C}(\v{x})$ liegt, also lässt sich schreiben
$$
\begin{align}
\v{p}-\v{x} \in \ncone{C}(\v{x}).
\end{align}
$$
Dies lässt sich mit obiger Beziehung direkt zu
$$
\begin{align}
\v{x} &= \prox{C}(\v{x} + \v{p} - \v{x}) \\
&= \prox{C}(\v{p}).
\end{align}
$$
umschreiben. Aus dem erkennen wir, dass der Ursprung des Normalkegels, worin ein **beliebiger** Punkt $\v{p}$ liegt, direkt der **proximale** Punkt ist zu $\v{p}$.

Müssten wir nun eine Projektionsfunktion auf ein $2$d-Dreieck herleiten, würden wir folgendes Bild malen:

<div class="img-with-caption">
    <img src="/files/NormalKegelDreieck.svg" style="max-width:400px;width:80%"/>
    <div class="caption" id="nomal-cone-vis">Normalkegel an die Punkte $\v{a}$, $\v{b}$ und $\v{c}$ eines Dreiecks.</div>
</div>

Das heisst es gibt genau 3 nicht triviale Normalkegel und 3 einfachere Normalkegel (bestehend lediglich aus den Normalen auf die Seitenflächen). Eine Projektionsfunktion auf ein Dreieck muss diese 6 Bereiche beachten und ist so auch optimal und richtig implementiert.

## Zusammenhang von Normalkegel und Konvexer Optimierung
Um hier mathematisch nicht in einen Exzess zu geraten, wird hier nur eine abgespeckte Erklärung gegeben. Für mehr Informationen sei auf [Kapitel 6 *Convex Optimization*](http://dx.doi.org/10.3929/ethz-a-010662262) verwiesen und die darin enthaltenen Referenzen.

Betrachte man folgendes allgemeine restriktierte **konvexe** Optimierungsproblem:
$$
\begin{equation}
\v{x}^* = \underset{\v{x} \ \in \ \set{C}}{\argmin} f(\v{x}),
\label{eq-convexproblem}
\end{equation}
$$
wobei die Funktion $f(\v{x}) \in \mathbb{R}$ **strikt konvex** und **differenzierbar** (man stelle sich den oberen Teil eines Weinglases vor, wobei $\v{x} \in \mathbb{R}^2$) ist und die minimierenden Punkte $\v{x}$ auf eine **konvexe** Menge $\set{C}$ restriktiert sind. Der minimierende Punkt ist hier mit $\v{x}^*$ bezeichnet. Es gibt nur **einen** solchen globalen minimierenden Punkt

Dann kann man das Problem in ein freies **konvexes** Programm umschreiben indem man die Einschränkung $\v{x} \in \set{C}$ mit einer Bestrafungsfunktion $\indf{C}(\v{x})$ ersetzt
$$
\begin{align}
\v{x}^* = \underset{\v{x}}{\argmin} f(\v{x}) + \indf{C}(\v{x}).
\end{align}
$$
Die Bestrafungsfunktion $\indf{C}(\v{x})$ liefert $0$ falls $\v{x} \in \set{C}$ und sonst $+\infty$. Diese Funktion wird **Indikatorfunktion** genannt.

Die Frage ist nun wie kriegen wir eine Bedingung an den optimalen (minimierenden) Punkt $\v{x}^*$.
Das geht ziemlich analog zu der Bedindung für Minima/Maxima einer differenzierbaren Funktionen $f$ :
$$
\begin{align}
\v{0} = \frac{df}{d\v{x}}(\v{x}^*)
\label{eq-optimality-difffunc}
\end{align}
$$
was konkret heisst, dass der Nullvektor $\v{0}$ gleich dem Gradient $\frac{df}{d\v{x}}$ ist an der optimalen Stelle $\v{x}^*$.

Da wir aber bei unserem Problem $\eqref{eq-convexproblem}$ diese **unstetige**, **nicht-differenzierbare** Bestrafungsfunktion $\indf{C}$ eingebaut haben, ist dies nicht direkt mit der normalen Differentiation zu machen. Man braucht in der konvexen Analysis eine verallgemeinerte Ableitung - das **Subdifferential**, welches nicht mehr nur einfache Steigungen (d.h. die Steigung für $1$-dimensionale Funktionen $f(x)$ oder allgemeiner der Gradient für $n$-dimensionale Funktionen $f(\v{x})$) zurück geben kann sondern auch **ganze Mengen** von solchen Steigungen. Das heisst, das Subdifferential an einem Punkt ist eine Menge aller Gradienten an diesen Punkt der Funktion.
Das heisst direkt, dass eine Gleicheit zu $\v{0}$ wie in $\eqref{eq-optimality-difffunc}$ nicht mehr richtig wäre und hier eine Mengen-Inklusion $\v{0} \in \dots$ stehen muss.

Anstatt $\frac{d}{d\v{x}}\indf{C}$ nehmen wir einfach das Subdifferential $\partial_{\v{x}} \indf{C}$ und die Bedingung $\eqref{eq-optimality-difffunc}$ wird dann zu
$$
\begin{align}
\v{0} \in \frac{df}{d\v{x}}(\v{x}^*) + \partial_{\v{x}} \indf{C}(\v{x}^*)
\label{eq-optimality-strict-convex}
\end{align}
$$
Nur was machen wir nun mit dieser **mengenwertigen Relation**?

Da man zeigen kann, dass das Subdifferential, also die mengenwertige Ableitung, der Indikatorfunktion $\partial_{\v{x}} \indf{C}(\v{x})$ genau dem Normalkegel $\ncone{C}(\v{x})$ entspricht, können wir die obige Inklusion so schreiben:
$$
\begin{align}
\v{0} \in \frac{df}{d\v{x}}(\v{x}^*) + \ncone{C}(\v{x}^*) \quad \Leftrightarrow \quad -\frac{df}{d\v{x}}(\v{x}^*) \in \ncone{C}(\v{x}^*)
\label{eq-optimality-strict-convex-2}
\end{align}
$$
Das bringt uns nicht viel mehr ausser einer visuellen Erkenntnis durch folgende Visualisierung:

<div class="img-with-caption">
    <img src="/files/ConvexOptimizationProblem.svg" style="max-width:600px;width:600px"/>
    <div class="caption" id="nomal-cone-vis">Konvexes Optimierungs Problem innerhalb der Menge $\set{C}$ auf einer $2$d-Funktion $f(\v{x}) \in \mathbb{R}$. Der negative Gradient liegt im Optimum $\v{x}^*$ genau innerhalb des Normalkegels an $\v{x}^*$.</div>
</div>

Mit der Beziehung zwischen **proximalem Punkt** und **Normalkegel** $\eqref{eq-prox-to-ncone}$ kriegen wir daraus direkt eine **implizite Projektionsgleichung** für den optimalen Punkt $\v{x}^*$:
$$
-\frac{df}{d\v{x}}(\v{x}^*) \in \ncone{C}(\v{x}^*) \quad \Leftrightarrow \quad \v{x}^* = \prox{C}(\v{x}^* - \frac{df}{d\v{x}}(\v{x}^*)),
$$
welche man iterative lösen kann, was zum **Gradienten-Projektionsverfahren** führt (Gradient Projection Algorithm).
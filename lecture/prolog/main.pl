successor(X,Y) :- Y is X + 1.

loves(vincent ,mia).
loves(marsellus ,mia).
jealous(A,B) :- loves(A,C) , loves(B,C).

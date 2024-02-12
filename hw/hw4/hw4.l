(defun MY-LENGTH (L)
    (cond ((null L) 0)
            (t (+ 1 (MY-LENGTH (cdr L)) ) )
    )
)

(defun MY-MEMQ (A L)
    (cond ((null L) nil)
           ((eq A (car L)) L)
           (t (MY-MEMQ A (cdr L)))
    )
)

(defun MY-APPEND (L1 L2)
    (cond ((null L1) L2)
        (t (cons (car L1) (my-append (cdr L1) L2)))
    )
)

(defun MY-REVERSE (L)
    (REVERSE-HELPER L nil)
)

(defun REVERSE-HELPER (L x)
    (cond
        ((null L) x)
        (t (REVERSE-HELPER (cdr L) (cons (car L) x)))    
    )
)

(defun MY-MAPCAR (F L)
    (cond 
        ((null L) nil)
        (t (cons (apply F (cons (car L) nil) ) (MY-MAPCAR F (cdr L)) ))
    )
)

(defun MY-COPY (L)
    (cond
        ((null L) nil)
        ((atom L) L)
        (t (cons (car L) (MY-COPY (cdr L)) ) )
    )
)

(defun MY-NTH (L N)
    (cond 
        ((= N 0) (cons 'nil L))
        ((= N 1) L)
        (t (MY-NTH (cdr L) (- N 1)))
    )
)

(defun MY-REMOVE (X L)
    (cond
        ((null L) nil)
        ((equal x (car L)) (MY-REMOVE x (cdr L)))
        (t (cons (car L) (MY-REMOVE x (cdr L))))
    )
)

(defun MY-SUBST (X Y Z)
    (cond
        ((null Z) nil)
        ((atom Z) 
            (cond 
                ((equal X Z) Y)
                (t Z)
            )
        )
        (t (cons 
            (MY-SUBST X Y (car Z)) 
            (MY-SUBST X Y (cdr Z))
            )
        )
    )
)

(defun MY-SUBSET (FN L)
    (cond
        ((null L) L)
        ((not 
            (null 
                (apply FN (cons (car L) nil) ) 
            )) (cons (car L) (MY-SUBSET FN (cdr L)))
        )
        (t (MY-SUBSET FN (cdr L)) )
    )
)

(defun MY-ADD (N1 N2)
    (MY-ADD-HELPER N1 N2 0)
)

(defun MY-ADD-HELPER (N1 N2 CARRY)
    (cond
        ((and (null N1) (null n2)) 
            (cond
                ((equal CARRY 1) (cons CARRY nil))
            )
        )
        ((null N1)
            (cond 
                ((> 10 (+ (car N2) CARRY)) 
                    (cons 
                        (mod (+ (car N2) CARRY) 10)
                        (MY-ADD-HELPER N1 (cdr N2) 0)
                    )
                )
                (t 
                    (cons 
                        (mod (+ (car N2) CARRY) 10) 
                        (MY-ADD-HELPER N1 (cdr N2) 1))
                    )
            )
        )
        ((null N2) 
            (cond 
                ((> 10 (+ (car N1) CARRY)) 
                    (cons 
                        (mod (+ (car N1) CARRY) 10)
                        (MY-ADD-HELPER (cdr N1) N2 0)
                    )
                )
                (t 
                    (cons 
                        (mod (+ (car N1) CARRY) 10) 
                        (MY-ADD-HELPER (cdr N1) N2 1)
                    )
                )
            )  
        )
        ( (> 10 (+ (car N1) (car N2) CARRY)) 
                (cons 
                    (+ (car N1) (car N2) CARRY) 
                    (MY-ADD-HELPER (cdr N1) (cdr N2) 0)
                )
        )
        (t (cons 
                (mod (+ (car N1) (car N2) CARRY) 10) 
                (MY-ADD-HELPER (cdr N1) (cdr N2) 1)
            ) 
        )
    )
)

(defun MY-MERGE (L1 L2)
    (cond
        ((null L1) L2)
        ((null L2) L1)
        ((<= (car L1) (car L2))
            (cons (car L1) (MY-MERGE (cdr L1) L2))
        )
        (t (cons (car L2) (MY-MERGE L1 (cdr L2)) ))
    )
)

(defun MY-SUBLIST (L1 L2)
    (MY-SUBLIST-HELPER L1 L2 nil)
)

(defun MY-SUBLIST-HELPER (L1 L2 sub)
    (cond
        ((null L1) t)
        ((null L2) nil)
        ((eq (car L1) (car L2)) (MY-SUBLIST-HELPER (cdr L1) (cdr L2) t))
        ((not sub) (MY-SUBLIST-HELPER L1 (cdr L2) nil))
    )
)

(defun MY-ASSOC (A ALIST)
    (cond
        ((null ALIST) nil)
        (t 
            (cond
                ((equal A (caar ALIST)) (car ALIST) )
                (t (MY-ASSOC A (cdr ALIST)))
            )
        )
    )
)

(defun MY-REPLACE (ALIST L)
    (cond
        ((null L) nil)
        ((atom L) 
            (cond 
                ((null ALIST) L)
                (t
                    (cond 
                        ((equal l (caar ALIST)) (cdar ALIST))
                        ((listp ALIST) (MY-REPLACE (cdr ALIST) L) )
                    )
                )
            )
        )
        (t (cons (MY-REPLACE ALIST (car L)) (MY-REPLACE ALIST (cdr L))) )
    )
)
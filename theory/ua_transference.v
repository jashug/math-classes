Require Import
  Morphisms Setoid Program
  abstract_algebra universal_algebra canonical_names
  theory.categories.

Require categories.variety.

Section contents.

  Context (et: EquationalTheory) `{Variety et A} `{Variety et B}
    `{!HomoMorphism et A B ab} `{!HomoMorphism et B A ba}
    (i: iso_arrows (variety.arrow et ab) (variety.arrow et ba)).

  Implicit Arguments ab [[a]].
  Implicit Arguments ba [[a]].

  Let ab_proper a: Proper (equiv ==> equiv) (@ab a).
  Proof. intro. apply _. Qed.

  Let ba_proper a: Proper (equiv ==> equiv) (@ba a).
  Proof. intro. apply _. Qed.

  Let epA: forall V n, Proper (equiv ==> eq ==> equiv) (@eval _ A _ V n) := _.
  Let epB: forall V n, Proper (equiv ==> eq ==> equiv) (@eval _ B _ V n) := _.
    (* hints. shouldn't be necessary *)

  Let ab_ba: forall b (a: B b), ab (ba a) == a := proj1 i.
  Let ba_ab: forall b (a: A b), ba (ab a) == a := proj2 i.

  Program Lemma transfer_eval n (t: Term et nat n) (v: Vars et B nat):
    eval et (A:=A) (fun _ i => ba (v _ i)) t == map_op _ (@ba) (@ab) (eval et v t).
  Proof with auto; try reflexivity.
   induction t; simpl in *; intros...
    set (eval et (fun (a : sorts et) (i : nat) => ba (v a i)) t2).
    pose proof (@epA nat (function (sorts et) y t1) (fun a i => ba (v a i))
         (fun a i => ba (v a i)) (reflexivity _) t2 t2 (reflexivity _)
         : Proper (equiv ==> op_type_equiv (sorts et) A t1)%signature o).
    rewrite (IHt2 v).
    subst o.
    pose proof (IHt1 v (ba (eval et v t3)) (ba (eval et v t3))).
    rewrite H2...
    pose proof (@map_op_proper (sorts et) B A _ _ _ _ _ _). apply H3.
    unfold compose in *.
    pose proof (epB _ _ v v (reflexivity _) t2 t2 (reflexivity _)). apply H4.
     (* can't apply these directly because of Coq bug *)
    apply ab_ba.
   generalize
     (@algebra_propers _ A _ _ _ o)
     (@algebra_propers _ B _ _ _ o).
   generalize (@preserves et A B _ _ _ _ (@ab) _ o).
   fold (@algebra_op et A _ o) (@algebra_op et B _ o).
   generalize (@algebra_op et A _ o), (@algebra_op et B _ o).
   induction (et o); simpl; repeat intro.
    rewrite <- ba_ab, H1...
   apply IHo0.
    cut (Preservation et A B (@ab) (o1 y) (o2 (ab y))). (* this cut shouldn't be necessary; get rid of it *)
     rewrite H4.
     intuition.
    apply H1.
   apply H2...
   apply H3...
  Qed. (* todo: make [reflexivity] work as a hint. further cleanup. *)
(*
  Program Lemma iso_vars (v: Vars et A nat): v == fun _ i => ba (ab (v _ i)).
  Proof. do 3 intro. rewrite ba_ab. reflexivity. Qed.
    (* todo: hm, what was that tactic/proper-signature that let one rewrite under binders? *)
 *)
  Program Lemma transfer_eval' n (t: Term et nat n) (v: Vars et B nat):
    map_op _ (@ab) (@ba) (eval et (A:=A) (fun _ i => ba (v _ i)) t) == eval et v t.
  Proof with auto.
   intros.
   pose proof (@map_op_proper (sorts et) A B _ _ _ _ _ _).
   rewrite (transfer_eval t v).
   apply (@map_iso _ A B _ _ (@ab) (@ba) ab_ba).
   apply _.
  Qed. 

  Program Lemma transfer_statement_and_vars (s: Statement et) (v: Vars et B nat):
    eval_stmt et v s <-> eval_stmt et (A:=A) (fun _ i => ba (v _ i)) s.
  Proof with auto; reflexivity.
   intros.
   induction s; simpl; intuition.
    rewrite transfer_eval. symmetry.
    rewrite transfer_eval. symmetry.
    apply (map_op_proper _ _ _)...
   rewrite <- transfer_eval'. symmetry.
   rewrite <- transfer_eval'. symmetry.
   apply (map_op_proper _ _ _)...
  Qed.

  Theorem transfer_statement (s: Statement et): (forall v, eval_stmt et (A:=A) v s) -> (forall v, eval_stmt et (A:=B) v s).
  Proof.
   intros s U v.
   assert (v == (fun _ i => ab (ba (v _ i)))).
    destruct i. intros a a0. symmetry. 
    apply ab_ba.
   rewrite H1, transfer_statement_and_vars. apply U.
  Qed.

End contents.
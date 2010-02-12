Set Automatic Introduction.

Require
  theory.rings categories.variety.
Require Import
  Program Morphisms
  abstract_algebra universal_algebra.

Inductive op := plus | mult | zero | one.

Section sig.

  Import op_type_notations.

  Definition sig: Signature := Build_Signature unit op
    (fun o => match o with
      | plus => tt -=> tt -=> constant _ tt
      | mult => tt -=> tt -=> constant _ tt
      | zero => constant _ tt
      | one => constant _ tt
      end)%nat.

End sig.

Section laws.

  Global Instance: RingPlus (Term sig nat (constant _ tt)) :=
    fun x => App sig _ _ _ (App sig _ _ _ (Op sig _ plus) x).
  Global Instance: RingMult (Term sig nat (constant _ tt)) :=
    fun x => App sig _ _ _ (App sig _ _ _ (Op sig _ mult) x).
  Global Instance: RingZero (Term sig nat (constant _ tt)) := Op sig _ zero.
  Global Instance: RingOne (Term sig nat (constant _ tt)) := Op sig _ one.

  Local Notation x := (Var sig _ 0%nat tt).
  Local Notation y := (Var sig _ 1%nat tt).
  Local Notation z := (Var sig _ 2 tt).

  Import notations.

  Inductive Laws: EqEntailment sig -> Prop :=
    |e_plus_assoc: Laws (x + (y + z) === (x + y) + z)
    |e_plus_comm: Laws (x + y === y + x)
    |e_plus_0_l: Laws (0 + x === x)
    |e_mult_assoc: Laws (x * (y * z) === (x * y) * z)
    |e_mult_comm: Laws (x * y === y * x)
    |e_mult_1_l: Laws (1 * x === x)
    |e_mult_0_l: Laws (0 * x === 0)
    |e_distr_l: Laws (x * (y + z) === x * y + x * z)
    |e_distr_r: Laws ((x + y) * z === x * z + y * z).

End laws.

Definition theory: EquationalTheory := Build_EquationalTheory sig Laws.

(* Given a SemiRing, we can make the corresponding Implementation, prove the laws, and
 construct the categorical object: *)

Section from_instance.

  Context A `{SemiRing A}.

  Instance implementation: AlgebraOps sig (fun _ => A) := fun o =>
    match o with plus => ring_plus | mult => ring_mult | zero => 0 | one => 1 end.

  Global Instance: Algebra sig _.
  Proof. constructor. intro. apply _. intro o. destruct o; simpl; try apply _; unfold Proper; reflexivity. Qed.

  Lemma laws e (l: Laws e) vars: eval_stmt sig vars e.
  Proof.
   inversion_clear l; simpl.
           apply associativity.
          apply commutativity.
         apply theory.rings.plus_0_l.
        apply associativity.
       apply commutativity.
      apply theory.rings.mult_1_l.
     apply mult_0_l.
    apply distribute_l.
   apply distribute_r.
  Qed.

  Instance variety: Variety theory (fun _ => A).
  Proof. constructor. apply _. exact laws. Qed.

  Definition Object := variety.Object theory.
  Definition Arrow := variety.Arrow theory.
  Definition object: Object := variety.object theory (fun _ => A).

End from_instance.

(* Similarly, given a categorical object, we can make the corresponding class instances: *)

Section ops_from_alg_to_sr. Context `{AlgebraOps theory A}.
  Global Instance: RingPlus (A tt) := algebra_op _ plus.
  Global Instance: RingMult (A tt) := algebra_op _ mult.
  Global Instance: RingZero (A tt) := algebra_op _ zero.
  Global Instance: RingOne (A tt) := algebra_op _ one.
End ops_from_alg_to_sr.

Lemma mor_from_sr_to_alg `{Variety theory A} `{Variety theory B}
  (f: forall u, A u -> B u) `{!SemiRing_Morphism (f tt)}: HomoMorphism sig A B f.
Proof.
 constructor.
    intros []. apply _.
   intros []; simpl.
      apply rings.preserves_plus.
     apply rings.preserves_mult.
    change (f tt 0 == 0). apply rings.preserves_0.
   change (f tt 1 == 1). apply rings.preserves_1.
  change (Algebra theory A). apply _.
 change (Algebra theory B). apply _.
Qed.

Instance struct_from_var_to_class `{v: Variety theory A}: SemiRing (A tt).
Proof with simpl; auto.
 repeat (constructor; try apply _); repeat intro.
               apply (variety_laws _ e_mult_assoc (fun s n => match s with tt => match n with 0 => x | 1 => y | _ => z end end))...
              apply (algebra_propers theory mult)...
             apply (variety_laws _ e_mult_1_l (fun s n => match s with tt => x end))...
            pose proof (variety_laws _ e_mult_comm (fun s n => match s with tt => match n with 0 => x | _ => algebra_op theory one end end)).
            simpl in H. rewrite H...
            apply (variety_laws _ e_mult_1_l (fun s n => match s with tt => x end))...
           apply (variety_laws _ e_plus_assoc (fun s n => match s with tt => match n with 0 => x | 1 => y | _ => z end end))...
          apply (algebra_propers theory plus)...
         apply (variety_laws _ e_plus_0_l (fun s n => match s with tt => x end))...
        pose proof (variety_laws _ e_plus_comm (fun s n => match s with tt => match n with 0 => x | _ => algebra_op theory zero end end)).
        simpl in H. rewrite H...
        apply (variety_laws _ e_plus_0_l (fun s n => match s with tt => x end))...
       apply (variety_laws _ e_plus_comm (fun s n => match s with tt => match n with 0 => x | _ => y end end))...
      apply (variety_laws _ e_mult_comm (fun s n => match s with tt => match n with 0 => x | _ => y end end))...
     apply (variety_laws _ e_distr_l (fun s n => match s with tt => match n with 0 => a | 1 => b | _ => c end end))...
    apply (variety_laws _ e_distr_r (fun s n => match s with tt => match n with 0 => a | 1 => b | _ => c end end))...
   apply (variety_laws _ e_mult_0_l (fun s n => match s with tt => x end))...
Qed.

  

(*
Section from_object. Variable o: variety.Object theory.

  Global Instance plu: RingPlus (o tt) := algebra_op theory plus.
  Global Instance: RingMult (o tt) := algebra_op theory mult.
  Global Instance: RingZero (o tt) := algebra_op theory zero.
  Global Instance: RingOne (o tt) := algebra_op theory one.
(*
  Definition from_object: SemiRing (o tt).
  Proof with simpl; auto.
   repeat (constructor; try apply _); repeat intro.
               apply (variety_laws theory _ _ e_mult_assoc (fun s n => match s with tt => match n with 0 => x | 1 => y | _ => z end end))...
              apply (variety_propers theory o mult)...
             apply (variety_laws theory _ _ e_mult_1_l (fun s n => match s with tt => x end))...
            pose proof (variety_laws theory _ _ e_mult_comm (fun s n => match s with tt => match n with 0 => x | _ => variety_op theory o one end end)).
            simpl in H. rewrite H...
            apply (variety_laws theory _ _ e_mult_1_l (fun s n => match s with tt => x end))...
           apply (variety_laws theory _ _ e_plus_assoc (fun s n => match s with tt => match n with 0 => x | 1 => y | _ => z end end))...
          apply (variety_propers theory o plus)...
         apply (variety_laws theory _ _ e_plus_0_l (fun s n => match s with tt => x end))...
        pose proof (variety_laws theory _ _ e_plus_comm (fun s n => match s with tt => match n with 0 => x | _ => variety_op theory o zero end end)).
        simpl in H. rewrite H...
        apply (variety_laws theory _ _ e_plus_0_l (fun s n => match s with tt => x end))...
       apply (variety_laws theory _ _ e_plus_comm (fun s n => match s with tt => match n with 0 => x | _ => y end end))...
      apply (variety_laws theory _ _ e_mult_comm (fun s n => match s with tt => match n with 0 => x | _ => y end end))...
     apply (variety_laws theory _ _ e_distr_l (fun s n => match s with tt => match n with 0 => a | 1 => b | _ => c end end))...
    apply (variety_laws theory _ _ e_distr_r (fun s n => match s with tt => match n with 0 => a | 1 => b | _ => c end end))...
   apply (variety_laws theory _ _ e_mult_0_l (fun s n => match s with tt => x end))...
  Qed.
*)
End from_object.

*)



(*
(* Finally, we can also convert morphism instances and categorical arrows: *)

Require Import categories.ua_variety.

Program Definition arrow_from_morphism_from_instance_to_object
  A `{SemiRing A} (B: Variety theory) (f: A -> B tt) {fmor: SemiRing_Morphism f}: Arrow theory (object A) B
  := fun u => match u return A -> B u with tt => f end.
Next Obligation.
 constructor. destruct a. apply _.
 destruct o; simpl.
    apply theory.rings.preserves_plus.
   apply theory.rings.preserves_mult.
  change (f 0 == 0). apply theory.rings.preserves_0.
 change (f 1 == 1). apply theory.rings.preserves_1.
Qed.

Section morphism_from_ua.

  Context  `{e0: Equiv R0} {R1: unit -> Type} `{e1: forall u, Equiv (R1 u)} `{!Equivalence e0}
    `{forall u, Equivalence (e1 u)}
    `{@Implementation sig (fun _ => R0)} `{@Implementation sig R1}
    (f: forall u, R0 -> R1 u)
      `{!@HomoMorphism sig (fun _ => R0) R1 (fun _ => e0) e1 _ _ f}.

  Global Instance: RingPlus R0 := @universal_algebra.op sig (fun _ => R0) _ plus.
  Global Instance: RingMult R0 := @universal_algebra.op sig (fun _ => R0) _ mult.
  Global Instance: RingZero R0 := @universal_algebra.op sig (fun _ => R0) _ zero.
  Global Instance: RingOne R0 := @universal_algebra.op sig (fun _ => R0) _ one.

  Global Instance: RingPlus (R1 u) := fun u => match u with tt => universal_algebra.op sig plus end.
  Global Instance: RingMult (R1 u) := fun u => match u with tt => universal_algebra.op sig mult end.
  Global Instance: RingZero (R1 u) := fun u => match u with tt => universal_algebra.op sig zero end.
  Global Instance: RingOne (R1 u) := fun u => match u with tt => universal_algebra.op sig one end.

  Lemma morphism_from_ua (sr0: SemiRing R0) (sr1: SemiRing (R1 tt)): forall u, SemiRing_Morphism (f u).
  Proof.
   destruct u.
   pose proof (@preserves sig (fun _ => _) R1 (fun _ => e0) e1 _ _ f _).
   destruct H2.
   repeat (constructor; try apply _).
      apply (H3 plus).
     apply (H3 zero).
    apply (H3 mult).
   apply (H3 one).
  Qed.

End morphism_from_ua.
*)

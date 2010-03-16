Set Automatic Introduction.

Require Import
  Ring.
Require Import
  Program Morphisms
  abstract_algebra canonical_names.

Implicit Arguments inv_l [[A] [e] [op] [unit] [inv] [Group]].
Implicit Arguments inv_r [[A] [e] [op] [unit] [inv] [Group]].

Section group_props. Context `{Group}.

  Lemma inv_involutive x: - - x = x.
  Proof.
   rewrite <- (monoid_left_id _ x) at 2.
   rewrite <- (inv_l (- x)).
   rewrite <- associativity.
   rewrite inv_l.
   rewrite right_identity.
   reflexivity.
  Qed.

  Global Instance: Injective group_inv.
  Proof. intros x y E. rewrite <- (inv_involutive x), <- (inv_involutive y), E. reflexivity. Qed.

  Lemma inv_zero: - mon_unit = mon_unit.
  Proof. rewrite <- (inv_l mon_unit) at 2. rewrite right_identity. reflexivity. Qed.

End group_props.

Lemma sg_inv_distr `{AbGroup} x y: - (x & y) = - x & - y.
Proof.
 rewrite <- (left_identity (- x & - y)).
 rewrite <- (inv_l (x & y)).
 rewrite <- associativity.
 rewrite <- associativity.
 rewrite (commutativity (- x) (- y)).
 rewrite (associativity y).
 rewrite inv_r.
 rewrite left_identity.
 rewrite inv_r.
 rewrite right_identity.
 reflexivity.
Qed.

Section semiring_props. Context `{SemiRing R}.

  Global Instance plus_0_r: RightIdentity ring_plus 0 := right_identity.
  Global Instance plus_0_l: LeftIdentity ring_plus 0 := left_identity.
  Global Instance mult_1_l: LeftIdentity ring_mult 1 := left_identity.
  Global Instance mult_1_r: RightIdentity ring_mult 1 := right_identity.

  Global Instance mult_0_r: RightAbsorb ring_mult 0.
  Proof. intro. rewrite commutativity. apply left_absorb. Qed.

  Lemma stdlib_semiring_theory: Ring_theory.semi_ring_theory 0 1 ring_plus ring_mult equiv.
  Proof with try reflexivity.
   constructor; intros.
          apply left_identity.
         apply commutativity.
        apply associativity.
       apply left_identity.
      apply left_absorb.
     apply commutativity.
    apply associativity.
   apply distribute_r.
  Qed.

End semiring_props.

Implicit Arguments stdlib_semiring_theory [[e] [plus0] [mult0] [zero] [one] [H]].

Section semiringmor_props. Context `{SemiRing_Morphism}.

  Existing Instance a_sg.
  Lemma preserves_0: f 0 = 0.
  Proof. intros. apply (@preserves_mon_unit _ _ _ _ _ _ _ _ f _). Qed.
  Lemma preserves_1: f 1 = 1.
  Proof. intros. apply (@preserves_mon_unit _ _ _ _ _ _ _ _ f _). Qed.
  Lemma preserves_mult: Π x y, f (x * y) = f x * f y.
  Proof. intros. apply preserves_sg_op. Qed.
  Lemma preserves_plus: Π x y, f (x + y) = f x + f y.
  Proof. intros. apply preserves_sg_op. Qed.

End semiringmor_props.

Section ring_props. Context `{Ring R}.

  Lemma stdlib_ring_theory: Ring_theory.ring_theory 0 1 ring_plus ring_mult (λ x y => x + - y) group_inv equiv.
  Proof.
   constructor; intros.
           apply left_identity.
          apply commutativity.
         apply associativity.
        apply left_identity.
       apply commutativity.
      apply associativity.
     apply distribute_r.
    reflexivity.
   apply (inv_r x).
  Qed.

  Add Ring R: stdlib_ring_theory.

  Instance: LeftAbsorb ring_mult 0.
  Proof. intro. ring. Qed.

  Global Instance Ring_Semi: SemiRing R.

  (* Hm, are the following really worth having as lemmas? *)

  Lemma plus_opp_r x: x + -x = 0. Proof. ring. Qed.
  Lemma plus_opp_l x: -x + x = 0. Proof. ring. Qed.
  Lemma plus_mul_distribute_r x y z: (x + y) * z = x * z + y * z. Proof. ring. Qed.
  Lemma plus_mul_distribute_l x y z: x * (y + z) = x * y + x * z. Proof. ring. Qed.
  Lemma opp_swap x y: x + - y = - (y + - x). Proof. ring. Qed.
  Lemma plus_opp_distr x y: - (x + y) = - x + - y. Proof. ring. Qed.
  Lemma ring_opp_mult a: -a = -(1) * a. Proof. ring. Qed.
  Lemma ring_distr_opp_mult a b: -(a * b) = -a * b. Proof. ring. Qed.
  Lemma ring_opp_mult_opp a b: -a * -b = a * b. Proof. ring. Qed.
  Lemma opp_0: -0 = 0. Proof. ring. Qed.
  Lemma ring_distr_opp a b: -(a+b) = -a+-b. Proof. ring. Qed.

  Lemma equal_by_zero_sum x y: x + - y = 0 → x = y.
  Proof. intro E. rewrite <- (plus_0_l y). rewrite <- E. ring. Qed.

  Global Instance: Π p: R, Injective (ring_plus p).
  Proof.
   intros p x y E.
   rewrite <- plus_0_l.
   rewrite <- (plus_opp_l p).
   rewrite <- associativity.
   rewrite E.
   ring.
  Qed.

  Lemma ring_plus_left_inj a a' b: a + b = a' + b → a = a'.
  Proof.
   intro E. apply (injective (ring_plus b)).
   rewrite commutativity, E. ring.
  Qed.

  Lemma units_dont_divide_zero (x: R) `{!RingMultInverse x} `{!RingUnit x}: ¬ ZeroDivisor x.
    (* todo: we don't want to have to mention RingMultInverse *)
  Proof with try ring.
   intros [x_nonzero [z [z_nonzero xz_zero]]].
   apply z_nonzero.
   transitivity (1 * z)...
   rewrite <- ring_unit_mult_inverse.
   transitivity (x * z * ring_mult_inverse x)...
   rewrite xz_zero...
  Qed.

  Lemma mult_ne_zero `{!NoZeroDivisors R}: Π (x y: R), x ≠ 0 → y ≠ 0 → x * y ≠ 0.
  Proof. repeat intro. apply (no_zero_divisors x). split; eauto. Qed.

  Global Instance mult_injective `{!NoZeroDivisors R} `{Π x y, Stable (x = y)} (x: R):
    x ≠ 0 → Injective (ring_mult x).
      (* this is the cancellation law in disguise *)
  Proof with intuition.
   intros x_nonzero y z E.
   apply stable.
   intro U.
   apply (mult_ne_zero x (y +- z) x_nonzero).
    intro. apply U. apply equal_by_zero_sum...
   rewrite distribute_l, E. ring.
  Qed.

End ring_props.

Implicit Arguments stdlib_ring_theory [[e] [plus0] [mult0] [inv] [zero] [one] [H]].

Section ringmor_props. Context `{Ring_Morphism A B f}.

  Lemma preserves_opp x: f (- x) = - f x.
  Proof. intros. apply preserves_inv. Qed.

  Global Instance Ring_Semi_Morphism: SemiRing_Morphism f.
  Proof. destruct H. constructor; apply _. Qed.

End ringmor_props.

Section morphism_composition.

  Context (A B C: Type)
    `{!RingMult A} `{!RingPlus A} `{!RingOne A} `{!RingZero A} `{!Equiv A}
    `{!RingMult B} `{!RingPlus B} `{!RingOne B} `{!RingZero B} `{!Equiv B}
    `{!RingMult C} `{!RingPlus C} `{!RingOne C} `{!RingZero C} `{!Equiv C}
    (f: A → B) (g: B → C).

  Global Instance id_semiring_morphism `{!SemiRing A}: SemiRing_Morphism id.
  Proof. repeat (constructor; try apply _); reflexivity. Qed.

  Global Instance compose_semiring_morphisms
    `{!SemiRing_Morphism f} `{!SemiRing_Morphism g}: SemiRing_Morphism (λ x => g (f x)).
  Proof with try reflexivity.
   pose proof (semiringmor_a).
   pose proof (semiringmor_b).
   pose proof (semiringmor_b: SemiRing C).
   assert (Proper (equiv ==> equiv) (λ x: A => g (f x))). intros x y E. rewrite E...
   repeat (constructor; try apply _); intros.
      do 2 rewrite preserves_sg_op...
     do 2 rewrite preserves_0...
    do 2 rewrite preserves_sg_op...
   do 2 rewrite preserves_1...
  Qed.

  Context `{!GroupInv A} `{!GroupInv B} `{!GroupInv C}.

  Global Instance id_ring_morphism `{!Ring A}: Ring_Morphism id.
  Proof. repeat (constructor; try apply _); reflexivity. Qed.

  Global Instance compose_ring_morphisms
    `{!Ring_Morphism f} `{!Ring_Morphism g}: Ring_Morphism (λ x => g (f x)).
  Proof.
   pose proof (ringmor_a).
   pose proof (ringmor_b).
   pose proof (ringmor_b: Ring C).
   repeat (constructor; try apply _).
   intros. do 2 rewrite preserves_inv. reflexivity.
  Qed.

End morphism_composition.

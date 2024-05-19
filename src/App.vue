<script setup>
import PetStoreForm from '@/components/PetStoreForm.vue'
import PetList from '@/components/PetList.vue'
import PetUpdateForm from '@/components/PetUpdateForm.vue'
</script>

<template>
  <v-row>
    <v-col
        cols="12"
        class="text-center"
    >
      <h1>Pet service</h1>
    </v-col>
  </v-row>
  <v-row>
    <v-col
        cols="12"
        md="6"
    >
      <PetStoreForm></PetStoreForm>
      <v-divider></v-divider>
      <PetUpdateForm></PetUpdateForm>
    </v-col>
    <v-col
        cols="12"
        md="6"
    >
      <PetList></PetList>
    </v-col>
  </v-row>
</template>

<style scoped>
header {
  line-height: 1.5;
}

@media (min-width: 1024px) {
  header {
    display: flex;
    place-items: center;
    padding-right: calc(var(--section-gap) / 2);
  }

  .logo {
    margin: 0 2rem 0 0;
  }

  header .wrapper {
    display: flex;
    place-items: flex-start;
    flex-wrap: wrap;
  }
}
</style>
